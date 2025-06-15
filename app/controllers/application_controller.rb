# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_sentry_context
  before_action :set_web_authn_warning
  prepend_before_action :reset_goto
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  add_flash_types :warning

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
    self.remembered_user = user
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
    self.current_user = if session[:user_id].present?
                          User.find_by(id: session[:user_id])
                        else
                          remembered_user
                        end
  end

  def remembered_user
    User.find_signed(cookies[remembered_user_cookie_name])
  end

  def remembered_user=(user)
    if user.nil?
      cookies.delete(remembered_user_cookie_name)
      return
    end

    cookies.permanent[remembered_user_cookie_name] = {
      value: user.signed_id(expires_in: 2.weeks),
      http_only: true,
      same_site: :strict
    }
  end

  def set_sentry_context
    return unless user_signed_in?

    Sentry.set_user(
      id: current_user.id,
      email: current_user.email
    )
  end

  def set_web_authn_warning
    return unless Settings.admin.web_authn_required && user_signed_in? && current_user.try(:admin?) &&
                  !current_user.web_authn_set_up?

    flash.now[:warning] = t('application.limited_permissions_without_web_authn_html',
                            web_authn_path: edit_members_member_path)
  end

  def user_not_authorized
    if user_signed_in?
      deny_access root_path
    else
      redirect_to_login_form warning: t('application.login_required')
    end
  end

  def redirect_to_login_form(options = {})
    session[:goto_after_login] = request.fullpath
    redirect_to login_path, options
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

  def remembered_user_cookie_name
    "_#{Rails.application.class.module_parent_name}_user_id"
  end
end
