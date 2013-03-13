class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user
  
  protected
  
  def authenticate_user
    @_member ||= (Member.find(session[:user_id]) if session[:user_id]) || Member.new
  end
  
  def restrict_access(group)
    if !@_member.id
      return redirect_to login_path, :flash => { :warning => t("application.login_required") }
    elsif ![:admin, group].include? @_member.group_name
      return redirect_to root_path, :alert => t("application.access_denied")
    end
  end
  
  def self.restrict_access_to_group(group, options = nil)
    before_filter options do |c|
      c.restrict_access group
    end
  end
  
end
