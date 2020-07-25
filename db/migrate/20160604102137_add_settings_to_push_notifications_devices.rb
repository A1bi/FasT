# frozen_string_literal: true

class AddSettingsToPushNotificationsDevices < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_push_notifications_devices, :settings, :text
  end
end
