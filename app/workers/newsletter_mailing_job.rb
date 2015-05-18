class NewsletterMailingJob
  @queue = :mailer_queue
  def self.perform(id, preview_email = nil)
    newsletter = Newsletter::Newsletter.find(id)

    if preview_email.present?
      subscribers = [Newsletter::Subscriber.new(email: preview_email)]
    else
      subscribers = Newsletter::Subscriber.all
    end

    subscribers.each do |subscriber|
      NewsletterMailer.newsletter(newsletter, subscriber).deliver
    end
  end
end
