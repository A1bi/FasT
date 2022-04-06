# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_sentry_context
  prepend_before_action :reset_goto
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  class << self
    protected

    def skip_authorization
      before_action :skip_authorization
    end

    def ignore_authenticity_token
      skip_before_action :verify_authenticity_token
    end
  end

  def disable_member_controls
    @no_member_controls = true
  end

  def reset_goto
    session.delete(:goto_after_login)
  end

  def render_cached_json(key, &)
    render_cached_json_if(key, true, &)
  end

  def render_cached_json_if(key, condition)
    json = if condition
             Rails.cache.fetch(key) { yield.to_json }
           else
             yield.to_json
           end
    render json:
  end

  protected

  def current_user
    @current_user ||= authenticate_user
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user&.id
  end

  def user_signed_in?
    current_user.present?
  end

  helper_method :current_user, :user_signed_in?

  def permanently_authenticated_user_id
    cookies.encrypted[permanent_user_id_cookie_name]
  end

  def permanently_authenticated_user=(user)
    if user.present?
      cookies.permanent.encrypted[permanent_user_id_cookie_name] = user.id
    else
      cookies.delete permanent_user_id_cookie_name
    end
  end

  private

  def authenticate_user
    user_id = session[:user_id] ||= permanently_authenticated_user_id
    return if user_id.nil?

    if (user = User.find_by(id: user_id)).nil?
      session[:user_id] = self.permanently_authenticated_user = nil
    end

    user
  end

  def set_sentry_context
    return unless user_signed_in?

    Sentry.set_user(
      id: current_user.id,
      email: current_user.email
    )
  end

  def user_not_authorized
    if user_signed_in?
      deny_access root_path
    else
      session[:goto_after_login] = request.url
      flash[:warning] = t('application.login_required')
      redirect_to login_path
    end
  end

  def deny_access(redirect_path)
    respond_to do |format|
      format.html do
        redirect_to redirect_path, alert: t('application.access_denied')
      end
      format.json do
        head :forbidden
      end
    end
  end

  def permanent_user_id_cookie_name
    "_#{Rails.application.class.module_parent_name}_user_id"
  end
end
