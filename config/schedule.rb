# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

every :day do
  runner 'Ticketing::BadgeResetPushNotificationsJob.perform_later'
end
