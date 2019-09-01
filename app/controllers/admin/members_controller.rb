module Admin
  class MembersController < BaseController
    before_action :find_groups, :only => [:new, :edit, :create, :update]
    before_action :find_member, :only => [:edit, :update, :destroy, :reactivate]
    before_action :prepare_new_member, :only => [:new, :create]
    before_action :update_member, :only => [:create, :update]
    before_action :find_members_for_family, only: %w[new create edit update]
    before_action :find_sepa_mandates, only: %i[new create edit update]

    def index
      @members = Members::Member.alphabetically
    end

    def new
    end

    def create
      @member.reset_password
      if @member.save
        send_activation_mail if params[:activation][:send] == "1"

        flash.notice = t('admin.members.created')
        redirect_to :action => :index
      else
        render :action => :new
      end
    end

    def edit
    end

    def update
      if @member.save
        redirect_to edit_admin_members_member_path(@member), notice: t("application.saved_changes")
      else
        render :action => :edit
      end
    end

    def destroy
      flash.notice = t('admin.members.destroyed') if @member.destroy
      redirect_to :action => :index
    end

    def reactivate
      @member.last_login = nil
      @member.reset_password
      send_activation_mail if @member.save

      redirect_to edit_admin_members_member_path(@member), notice: t("admin.members.sent_activation_mail")
    end

    protected

    def find_groups
      @groups = [];
      Members::Member.groups.keys.each do |group|
        @groups << [t("members.groups." + group), group]
      end
    end

    def find_member
      @member = Members::Member.find(params[:id])
      @member.build_sepa_mandate if @member.sepa_mandate.blank?
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
      @member = Members::Member.new
      @member.build_sepa_mandate
      @member
    end

    def update_member
      @member.assign_attributes(member_params)

      if @member.will_save_change_to_sepa_mandate_id?
        if @member.sepa_mandate_id.zero?
          @member.sepa_mandate = nil
          return if sepa_mandate_params[:iban].blank?

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

    def member_params
      params.require(:members_member).permit(
        :email, :first_name, :last_name, :nickname, :street,
        :plz, :city, :phone, :birthday, :family_member_id,
        :family_id, :joined_at, :group, :sepa_mandate_id
      )
    end

    def sepa_mandate_params
      @sepa_mandate_params ||= params.require(:members_member)
                                     .require(:members_sepa_mandate)
                                     .permit(:debtor_name, :iban, :number)
    end

    def send_activation_mail
      MemberMailer.activation(@member).deliver_later
    end
  end
end
