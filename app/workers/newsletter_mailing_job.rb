class NewsletterMailingJob
  @queue = :mailer_queue
  def self.perform(id)
    newsletter = Newsletter::Newsletter.find(id)
    Newsletter::Subscriber.all.each do |subscriber|
      NewsletterMailer.newsletter(newsletter, subscriber).deliver
    end
  end
end
