# frozen_string_literal: true

# this is necessary for jobs like ActionMailer::MailDeliveryJob which do not inherit from ApplicationJob
# to also have enqueue_after_transaction_commit enabled
# see https://github.com/rails/rails/pull/53375#issuecomment-2632770426

Rails.application.config.after_initialize do
  ActiveSupport.on_load(:active_job) do
    ActiveJob::Base.enqueue_after_transaction_commit = true
  end
end
