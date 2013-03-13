class Members::SessionsController < Members::MembersController
	ignore_restrictions
	
  def create
    member = Member.where({:email => params[:email]}).first
    if member && member.authenticate(params[:password])
      session[:user_id] = member.id
			member.last_login = Time.zone.now
			member.save
      redirect_to root_path
    else
      flash.now.alert = t("sessions.auth_error")
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, :notice => t("sessions.logout")
  end
end
