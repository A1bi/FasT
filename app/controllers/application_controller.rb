class ApplicationController < ActionController::Base
  protect_from_forgery
  attr_writer :restricted_to_group
	
  before_filter :authenticate_user
  
  protected
  
  def authenticate_user
		begin
			@_member ||= Members::Member.find(session[:user_id]) if session[:user_id]
		rescue
			session[:user_id] = nil
		end
		@_member ||= Members::Member.new
  end
  
  def restrict_access
    if !@_member.id
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
end
