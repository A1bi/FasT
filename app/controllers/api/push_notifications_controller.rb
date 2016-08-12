class Api::PushNotificationsController < ApplicationController
  def register
    device = Ticketing::PushNotifications::Device.find_or_initialize_by(token: params[:token], app: params[:app])
    device.settings = params.require(:settings).permit(:sound_enabled)
    device.save
    head :ok
  end
end
