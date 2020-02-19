module Members
  class MemberController < ApplicationController
    def activate
      authorize Member
      @member = Member.find_by(activation_code: params[:code])
      redirect_to_login if params[:code].blank? || @member.nil?
    end

    def finish_activation
      @member = authorize Member.find(params[:members_member][:id])
      return redirect_to_login if @member.activation_code != params[:members_member][:activation_code]

      @member.password = params[:members_member][:password]
      @member.password_confirmation = params[:members_member][:password_confirmation]
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
      member = Member.find_by_email(params[:members_member][:email])
      if !member
        flash.alert = t('.email_not_found')
        redirect_to action: :forgot_password
      else
        member.set_activation_code
        member.save

        MemberMailer.reset_password(member).deliver_later

        flash.notice = t('.password_reset')
        redirect_to_login
      end
    end

    private

    def redirect_to_login
      redirect_to login_path
    end
  end
end
