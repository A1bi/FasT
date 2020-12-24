# frozen_string_literal: true

module Api
  class PushNotificationsController < ApiController
    def register
      device.settings = params.require(:settings).permit(:sound_enabled).to_h
      head device.save ? :ok : :unprocessable_entity
    end

    private

    def device
      @device ||= ::Ticketing::PushNotifications::Device.find_or_initialize_by(
        token: params[:token], app: params[:app]
      )
    end
  end
end
