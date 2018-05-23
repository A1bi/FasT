class NewsletterMailingJob
  @queue = :mailer_queue

  def self.perform(id, preview_email = nil)
    newsletter = Newsletter::Newsletter.find(id)

    recipients = if preview_email.present?
                   [Newsletter::Subscriber.new(email: preview_email)]
                 else
                   newsletter.recipients
                 end

    recipients.each do |recipient|
      NewsletterMailer.newsletter(newsletter, recipient).deliver
    end
  end
end
