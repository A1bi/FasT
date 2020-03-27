# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

env 'MAILTO', 'albrecht@oster.online'

# whenever does not need to prefix jobs with bash to load the environment
# as we are not using RVM in production
set :job_template, nil

every :day do
  runner 'Ticketing::BadgeResetPushNotificationsJob.perform_later'
  runner 'Newsletter::SubscriberCleanupJob.perform_later'
end
