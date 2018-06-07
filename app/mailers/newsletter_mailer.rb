class NewsletterMailer < BaseMailer
  def confirmation_instructions(subscriber, after_order: false)
    @subscriber = subscriber
    @after_order = after_order
    @skip_unsubscribe_link = true
    mail to: subscriber.email
  end

  def newsletter(newsletter, subscriber)
    @subscriber = subscriber
    @newsletter = newsletter
    mail to: subscriber.email, subject: newsletter.subject
  end
end
