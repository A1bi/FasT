class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_writer :restricted_to_group
	
  before_filter :authenticate_user
  after_filter :reset_goto
  
  protected
  
  def authenticate_user
		begin
      session[:user_id] ||= user_id_cookie if user_id_cookie.present?
			@_member ||= Members::Member.find(session[:user_id]) if session[:user_id].present?
		rescue
			session[:user_id] = nil
		end
		@_member ||= Members::Member.new
    Ticketing::LogEvent.set_logging_member(@_member)
  end
  
  def restrict_access
    @skip_reset_goto = true
    if !@_member.id
      session[:goto_after_login] = request.original_url
      @skip_reset_goto = false
      return redirect_to members_login_path, :flash => { :warning => t("application.login_required") }
    elsif ![:admin, @restricted_to_group].include? @_member.group_name
      return redirect_to members_root_path, :alert => t("application.access_denied")
    end
  end
	
	def self.ignore_restrictions(options = {})
		skip_filter :restrict_access, options
	end
  
  def self.restrict_access_to_group(group, options = {})
		before_filter options do |c|
			c.restricted_to_group = group
		end
    before_filter :restrict_access, options
  end
  
	def disable_slides
		@no_slides = true
	end
	
	def disable_member_controls
		@no_member_controls = true
	end
  
  def user_id_cookie
    cookies.signed[user_id_cookie_name]
  end
  
  def user_id_cookie=(value)
    cookies.permanent.signed[user_id_cookie_name] = value
  end
  
  def delete_user_id_cookie
    cookies.delete user_id_cookie_name
  end
  
  private
  
  def user_id_cookie_name
    "_#{Rails.application.class.parent_name}_user_id"
  end
  
  def reset_goto
    session.delete(:goto_after_login) if !@skip_reset_goto
  end
end
