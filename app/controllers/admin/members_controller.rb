# frozen_string_literal: true

module Admin
  class MembersController < ApplicationController
    before_action :find_groups, only: %i[new edit create update]
    before_action :find_member, only: %i[show edit update destroy reactivate
                                         resume_membership_fee_payments]
    before_action :build_sepa_mandate, only: %i[edit update]
    before_action :prepare_new_member, only: %i[new create]
    before_action :find_members_for_family, only: %i[new create edit update]
    before_action :find_sepa_mandates, only: %i[new create edit update]

    def index
      @members = authorize Members::Member.alphabetically
    end

    def show; end

    def new; end

    def edit; end

    def create
      update_member
      @member.reset_password
      return render :new unless @member.save

      send_welcome_email
      send_activation_email(delayed: true)

      redirect_to admin_members_member_path(@member), notice: t('.created')
    end

    def update
      case params[:members_member][:cancelled]
      when 'true'
        @member.terminate_membership!
        notice = t('.cancelled')
      when 'false'
        @member.revert_membership_termination!
        notice = t('.cancellation_reverted')
      else
        update_member
        return render :edit unless @member.save

        notice = t('application.saved_changes')
      end

      redirect_to admin_members_member_path(@member), notice:
    end

    def destroy
      flash.notice = t('.destroyed') if @member.destroy
      redirect_to admin_members_members_path
    end

    def reactivate
      @member.last_login = nil
      @member.reset_password
      send_activation_email if @member.save

      redirect_to admin_members_member_path(@member),
                  notice: t('.sent_activation_mail')
    end

    def resume_membership_fee_payments
      @member.update(membership_fee_payments_paused: false)

      redirect_to admin_members_member_path(@member),
                  notice: t('.membership_fee_payments_resumed')
    end

    protected

    def find_groups
      @groups = Members::Member.groups.keys.map do |group|
        [t("members.groups.#{group}"), group]
      end
    end

    def find_member
      @member = authorize Members::Member.find(params[:id])
    end

    def find_members_for_family
      @members = Members::Member.where.not(id: @member).alphabetically
    end

    def find_sepa_mandates
      @sepa_mandates = {
        family: @member.family&.sepa_mandates,
        all: Members::SepaMandate.order(:number)
      }.compact
    end

    def prepare_new_member
      @member = authorize Members::Member.new
      @member.build_sepa_mandate
      @member
    end

    def update_member
      attrs = permitted_attributes(@member)
      attrs[:permissions] ||= [] if attrs[:permissions]
      attrs[:shared_email_accounts_authorized_for] ||= []
      @member.assign_attributes(attrs)

      # remove emails not allowed to be authorized for
      @member.shared_email_accounts_authorized_for&.select! do |email|
        email.in? shared_email_accounts
      end

      # skip mandate update if only the family needs to be removed
      return if params[:members_member] == { 'family_id' => '' }

      update_sepa_mandate
    end

    def build_sepa_mandate
      @member.build_sepa_mandate if @member.sepa_mandate.blank?
    end

    def update_sepa_mandate
      if @member.will_save_change_to_sepa_mandate_id?
        if @member.sepa_mandate_id.zero?
          @member.sepa_mandate = nil
          return if @member.persisted? && sepa_mandate_params[:iban].blank?

          @member.build_sepa_mandate(sepa_mandate_params)
        end

      else
        # do not change the IBAN if it is still obfuscated and therefore has not been changed by the user
        sepa_mandate_params.delete(:iban) if sepa_mandate_params[:iban].include? 'XXX'

        @member.sepa_mandate.update(sepa_mandate_params)
      end
    end

    def sepa_mandate_params
      @sepa_mandate_params ||= params.require(:members_member)
                                     .require(:members_sepa_mandate)
                                     .permit(:debtor_name, :iban, :number,
                                             :issued_on)
    end

    def send_welcome_email
      member_mailer.welcome.deliver_later
    end

    def send_activation_email(delayed: false)
      member_mailer.activation.deliver_later(wait: (delayed ? 1 : 0).minutes)
    end

    def member_mailer
      Members::MemberMailer.with(member: @member)
    end

    def shared_email_accounts
      Rails.application.credentials
           .shared_email_accounts[:credentials].pluck(:email)
    end
    helper_method :shared_email_accounts
  end
end
