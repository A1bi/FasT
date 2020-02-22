# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_authorization
  skip_before_action :reset_goto

  def new; end

  def create
    if user&.authenticate(params[:password])
      self.current_user = user
      self.permanently_authenticated_user = user if params[:remember].present?
      user.logged_in
      user.save
      redirect_to goto_path
    else
      flash.now.alert = t('.auth_error')
      render :new
    end
  end

  def destroy
    self.current_user = nil
    self.permanently_authenticated_user = nil
    redirect_to root_path, notice: t('.logout')
  end

  private

  def user
    @user ||= User.find_by_email(params[:email])
  end

  def goto_path
    return session[:goto_after_login] if session[:goto_after_login].present?
    return new_privileged_ticketing_order_path if user.retail?
    return members_root_path if user.member?

    root_path
  end
end
