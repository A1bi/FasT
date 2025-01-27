# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSession

  skip_authorization

  def new; end

  def create
    if user.blank?
      show_error('credentials_incorrect')
    elsif user.web_authn_required?
      show_error('web_authn_required')
    else
      log_in_user(user)
      redirect_to goto_path
    end
  end

  def destroy
    log_out_user
    redirect_to root_path
  end

  private

  def show_error(error)
    flash.now.alert = t(".#{error}")
    render :new
  end

  def user
    @user ||= User.authenticate_by(params.permit(:email, :password))
  end
end
