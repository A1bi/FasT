module Admin
  class MembersController < ApplicationController
    before_action :find_groups, only: %i[new edit create update]
    before_action :find_member, only: %i[show edit update destroy reactivate]
    before_action :build_sepa_mandate, only: %i[edit update]
    before_action :prepare_new_member, only: %i[new create]
    before_action :update_member, only: %i[create update]
    before_action :find_members_for_family, only: %i[new create edit update]
    before_action :find_sepa_mandates, only: %i[new create edit update]

    def index
      @members = authorize Members::Member.alphabetically
    end

    def new; end

    def create
      @member.reset_password
      return render :new unless @member.save

      send_activation_mail if params[:activation][:send] == '1'

      redirect_to admin_members_member_path(@member), notice: t('.created')
    end

    def show; end

    def edit; end

    def update
      render :edit unless @member.save

      redirect_to admin_members_member_path(@member),
                  notice: t('application.saved_changes')
    end

    def destroy
      flash.notice = t('.destroyed') if @member.destroy
      redirect_to action: :index
    end

    def reactivate
      @member.last_login = nil
      @member.reset_password
      send_activation_mail if @member.save

      redirect_to admin_members_member_path(@member),
                  notice: t('.sent_activation_mail')
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
      @member.assign_attributes(permitted_attributes(@member))

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
        # do not change the IBAN if it is still obfuscated and therefore
        # has not been changed by the user
        if sepa_mandate_params[:iban].include? 'XXX'
          sepa_mandate_params.delete(:iban)
        end

        @member.sepa_mandate.update(sepa_mandate_params)
      end
    end

    def sepa_mandate_params
      @sepa_mandate_params ||= params.require(:members_member)
                                     .require(:members_sepa_mandate)
                                     .permit(:debtor_name, :iban, :number,
                                             :issued_on)
    end

    def send_activation_mail
      MemberMailer.activation(@member).deliver_later
    end
  end
end
