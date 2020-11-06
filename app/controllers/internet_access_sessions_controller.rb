# frozen_string_literal: true

class InternetAccessSessionsController < ApplicationController
  layout 'minimal'

  def new
    authorize :internet_access_session

    render :unlocked if session_ongoing?
  end

  def create
    unless user&.authenticate(params[:password])
      flash.now.alert = t('.auth_error')
      skip_authorization
      return render :new
    end

    self.current_user = user

    authorize :internet_access_session

    self.session_ongoing = true
    redirect_to_landing
  end

  private

  def user
    @user ||= User.find_by_email(params[:email])
  end

  def session_ongoing?
    self.session_ongoing = false unless user_signed_in?
    session[:session_ongoing]
  end

  def session_ongoing=(ongoing)
    session[:session_ongoing] = ongoing
  end

  def user_not_authorized
    flash.alert = t('.not_authorized')
    redirect_to_landing
  end

  def redirect_to_landing
    redirect_to action: :new
  end
end
