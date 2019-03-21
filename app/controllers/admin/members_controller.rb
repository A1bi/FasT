module Admin
  class MembersController < BaseController
    before_action :find_groups, :only => [:new, :edit, :create, :update]
    before_action :find_member, :only => [:edit, :update, :destroy, :reactivate]
    before_action :prepare_new_member, :only => [:new, :create]
    before_action :update_member, :only => [:create, :update]
    before_action :find_members_for_family, only: %w[new create edit update]

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
    end

    def find_members_for_family
      @members = Members::Member.where.not(id: @member).alphabetically
    end

    def prepare_new_member
      @member = Members::Member.new
    end

    def update_member
      @member.assign_attributes(member_params)
    end

    def member_params
      params.require(:members_member).permit(:email, :first_name, :last_name, :nickname, :group, :birthday, :family_member_id, :family_id)
    end

    def send_activation_mail
      MemberMailer.activation(@member).deliver_later
    end
  end
end
