class Api::PushNotificationsController < ApplicationController
  def register
    Ticketing::PushNotifications::Device.create(token: params[:token], app: params[:app])
    render nothing: true
  end
end