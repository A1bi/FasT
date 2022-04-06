# frozen_string_literal: true

module Newsletter
  class MailingJob < ApplicationJob
    queue_as :mailers

    def perform(newsletter)
      newsletter.recipients.each do |recipient|
        NewsletterMailer.with(newsletter:, subscriber: recipient).newsletter.deliver_later
      end
    end
  end
end
