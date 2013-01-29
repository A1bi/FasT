class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :authenticate_user
  
  def authenticate_user
    @_member ||= Member.find(session[:user_id]) || Member.new if session[:user_id]
  end
end
