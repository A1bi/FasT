# frozen_string_literal: true

class CreateTicketingPushNotificationsWebSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :ticketing_push_notifications_web_subscriptions do |t|
      t.string :endpoint, null: false
      t.string :p256dh, null: false
      t.string :auth, null: false
      t.timestamps
    end

    drop_table :ticketing_push_notifications_devices do |t|
      t.string :token
      t.string :app
      t.text :settings, null: false
      t.timestamps
    end
  end
end
