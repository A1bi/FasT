# frozen_string_literal: true

class AddUserIdToTicketingPushNotificationsSubscriptions < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up { execute 'DELETE FROM ticketing_push_notifications_web_subscriptions' }
    end

    add_belongs_to :ticketing_push_notifications_web_subscriptions, :user, null: false, foreign_key: true
  end
end
