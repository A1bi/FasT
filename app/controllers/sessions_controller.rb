# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSession

  skip_authorization

  def new; end

  def create
    if user&.authenticate(params[:password])
      log_in_user(user)
      redirect_to goto_path
    else
      flash.now.alert = t('.auth_error')
      render :new
    end
  end

  def destroy
    log_out_user
    redirect_to root_path, notice: t('.logout')
  end

  private

  def user
    @user ||= User.find_by_email(params[:email])
  end
end
