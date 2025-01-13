# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_sentry_context
  prepend_before_action :reset_goto
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  class << self
    protected

    def skip_authorization(options = {})
      before_action :skip_authorization, options
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

  def event_page_exists?(event)
    template_exists?("events/#{event.identifier}")
  end

  helper_method :event_page_exists?

  private

  def authenticate_user
    return if session[:user_id].nil?

    session[:user_id] = nil if (user = User.find_by(id: session[:user_id])).nil?
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
      flash[:warning] = t('application.login_required')
      redirect_to_login_form
    end
  end

  def redirect_to_login_form
    session[:goto_after_login] = request.fullpath
    redirect_to login_path
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
end
