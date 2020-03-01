# frozen_string_literal: true

module Members
  class MemberController < ApplicationController
    def activate
      @member = authorize Member.find_by!(
        activation_code: params.require(:code)
      )
    end

    def finish_activation
      @member = authorize Member.find_by!(member_params
                                          .permit(:id, :activation_code))

      @member.assign_attributes(
        member_params.permit(:password, :password_confirmation)
      )

      if @member.valid?
        @member.activate

        session[:user_id] = @member.id

        flash.notice = if @member.last_login
                         t('.password_changed')
                       else
                         t('.activated')
                       end
        redirect_to members_root_path

        @member.logged_in
        @member.save
      else
        render action: :activate
      end
    end

    def edit
      authorize current_user, policy_class: MemberPolicy
    end

    def update
      authorize(current_user, policy_class: MemberPolicy)
        .assign_attributes(permitted_attributes(current_user))
      if current_user.save(context: :user_update)
        flash.notice = t('application.saved_changes')
        redirect_to action: :edit
      else
        render action: :edit
      end
    end

    def forgot_password
      authorize Member
    end

    def reset_password
      authorize Member
      member = Member.find_by_email(member_params[:email])
      if !member
        flash.alert = t('.email_not_found')
        redirect_to action: :forgot_password
      else
        member.set_activation_code
        member.save

        MemberMailer.with(member: member).reset_password.deliver_later

        flash.notice = t('.password_reset')
        redirect_to_login
      end
    end

    private

    def member_params
      params.require(:members_member)
    end

    def redirect_to_login
      redirect_to login_path
    end
  end
end
