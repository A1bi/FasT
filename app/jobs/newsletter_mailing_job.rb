# frozen_string_literal: true

class NewsletterMailingJob < ApplicationJob
  queue_as :mailers

  def perform(newsletter)
    newsletter.recipients.each do |recipient|
      NewsletterMailer.with(newsletter: newsletter, subscriber: recipient)
                      .newsletter.deliver_later
    end
  end
end
