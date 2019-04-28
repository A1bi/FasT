class ApplicationController < ActionController::Base
  attr_writer :restricted_to_group

  before_action :set_raven_context
  prepend_before_action :reset_goto

  class << self
    protected

    def ignore_restrictions(options = {})
      skip_before_action :restrict_access, options
    end

    def restrict_access_to_group(group, options = {})
      before_action options do |c|
        c.restricted_to_group = group
      end
      before_action :restrict_access, options
    end

    def ignore_authenticity_token
      skip_before_action :verify_authenticity_token
    end
  end

  def disable_slides
    @no_slides = true
  end

  def disable_member_controls
    @no_member_controls = true
  end

  def reset_goto
    session.delete(:goto_after_login)
  end

  def render_cached_json(key, &block)
    render_cached_json_if(key, true, &block)
  end

  def render_cached_json_if(key, condition)
    json = if condition
             Rails.cache.fetch(key) { yield.to_json }
           else
             yield.to_json
           end
    render json: json
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

    user = Members::Member.find_by(id: user_id)
    session[:user_id] = self.permanently_authenticated_user = nil if user.nil?

    Ticketing::LogEvent.user = user
    user
  end

  def set_raven_context
    if user_signed_in?
      Raven.user_context(
        id: current_user.id,
        email: current_user.email
      )
    end
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def restrict_access
    if !user_signed_in?
      session[:goto_after_login] = request.original_url
      redirect_to members_login_path, flash: { warning: t('application.login_required') }
    elsif Members::Member.groups[@restricted_to_group] > Members::Member.groups[current_user.group]
      redirect_to members_root_path, alert: t('application.access_denied')
    end
  end

  def permanent_user_id_cookie_name
    "_#{Rails.application.class.parent_name}_user_id"
  end
end
