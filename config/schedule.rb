# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

env 'MAILTO', 'albrecht@oster.online'

# whenever does not need to prefix jobs with bash to load the environment
# as we are not using RVM in production
set :job_template, nil
set :chronic_options, hours24: true

every :day do
  runner 'Ticketing::AnonymizeOrdersJob.perform_later'
  runner 'Newsletter::SubscriberCleanupJob.perform_later'
  runner 'SharedEmailAccountTokensCleanupJob.perform_later'
  runner 'Members::DestroyTerminatedMembersJob.perform_later'
end

every :day, at: '10:30' do
  runner 'Members::RenewMembershipsJob.perform_later'
end

every :day, at: '08:00' do
  runner 'Ticketing::ProcessReceivedTransferPaymentsJob.perform_later'
end

every :weekday, at: '09:00' do
  runner 'Ticketing::SendPayRemindersJob.perform_later'
end

every :weekday, at: '11:45' do
  runner 'Ticketing::SubmitBankTransactionsJob.perform_later'
end
