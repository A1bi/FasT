class AddSettingsToPushNotificationsDevices < ActiveRecord::Migration
  def change
    add_column :ticketing_push_notifications_devices, :settings, :text
  end
end
