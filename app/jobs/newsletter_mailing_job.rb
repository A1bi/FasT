# frozen_string_literal: true

class NewsletterMailingJob < ApplicationJob
  queue_as :mailers

  def perform(id, preview_email = nil)
    newsletter = Newsletter::Newsletter.find(id)

    recipients = if preview_email.present?
                   [Newsletter::Subscriber.new(email: preview_email)]
                 else
                   newsletter.recipients
                 end

    recipients.each do |recipient|
      NewsletterMailer.with(newsletter: newsletter, subscriber: recipient)
                      .newsletter.deliver_later
    end
  end
end
