# frozen_string_literal: true

class SessionsController < ApplicationController
  include UserSession

  skip_authorization

  def new; end

  def create
    if user&.web_authn_required?
      show_error('web_authn_required')
    elsif user&.authenticate(params[:password])
      log_in_user(user)
      redirect_to goto_path
    else
      show_error('credentials_incorrect')
    end
  end

  def destroy
    log_out_user
    redirect_to root_path, notice: t('.logout')
  end

  private

  def show_error(error)
    flash.now.alert = t(".#{error}")
    render :new
  end

  def user
    @user ||= User.find_by_email(params[:email])
  end
end
