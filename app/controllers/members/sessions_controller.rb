module Members
  class SessionsController < BaseController
    ignore_restrictions
    skip_filter :reset_goto

    def create
      member = Member.where({:email => params[:email]}).first
      if member && member.authenticate(params[:password])
        session[:user_id] = member.id
        self.user_id_cookie = member.id if params[:remember].present?
        member.logged_in
        member.save
        redirect_to session[:goto_after_login] || members_root_path
      else
        flash.now.alert = t("members.sessions.auth_error")
        render :new
      end
    end

    def destroy
      session[:user_id] = nil
      delete_user_id_cookie
      redirect_to root_path, :notice => t("members.sessions.logout")
    end
  end
end
