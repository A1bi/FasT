# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user
  
  protected
  
  def authenticate_user
    @_member ||= (Member.find(session[:user_id]) if session[:user_id]) || Member.new
  end
  
  def restrict_access(group)
    if !@_member.id
      flash.alert = "Bitte loggen Sie sich ein!"
      return redirect_to login_path
    elsif ![:admin, group].include? @_member.group
      flash.alert = "Sie haben nicht die erforderlichen Rechte für diese Aktion!"
      return redirect_to root_path
    end
  end
  
  def self.restrict_access_to_group(group, options = nil)
    before_filter options do |c|
      c.restrict_access group
    end
  end
  
end
