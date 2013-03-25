module Members
	class SessionsController < BaseController
		ignore_restrictions
	
	  def create
	    member = Member.where({:email => params[:email]}).first
	    if member && member.authenticate(params[:password])
	      session[:user_id] = member.id
				member.logged_in
				member.save
	      redirect_to members_root_path
	    else
	      flash.now.alert = t("members.sessions.auth_error")
	      render :new
	    end
	  end

	  def destroy
	    session[:user_id] = nil
	    redirect_to root_path, :notice => t("members.sessions.logout")
	  end
	end
end
