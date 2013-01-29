class SessionsController < ApplicationController
  def create
    member = Member.where({:email => params[:email]}).first
    if member && member.authenticate(params[:password])
      session[:user_id] = member.id
      redirect_to root_path
    else
      flash.now.alert = "E-mail-Adresse oder Passwort falsch!"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
