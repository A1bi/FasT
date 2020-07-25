# frozen_string_literal: true

class CreatePushNotificationsDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_push_notifications_devices do |t|
      t.string :token
      t.string :app
      t.timestamps
    end
  end
end
