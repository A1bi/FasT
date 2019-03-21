module Members
  class SessionsController < BaseController
    ignore_restrictions
    skip_before_action :reset_goto

    def create
      user = Member.find_by(email: params[:email])
      if user&.authenticate(params[:password])
        self.current_user = user
        self.permanently_authenticated_user = user if params[:remember].present?
        user.logged_in
        user.save
        redirect_to session[:goto_after_login] || members_root_path
      else
        flash.now.alert = t('members.sessions.auth_error')
        render :new
      end
    end

    def destroy
      self.current_user = nil
      self.permanently_authenticated_user = nil
      redirect_to root_path, notice: t('members.sessions.logout')
    end
  end
end
