class NewsletterMailer < BaseMailer
  def subscribed(subscriber)
    @subscriber = subscriber
    mail to: subscriber.email
  end

  def newsletter(newsletter, subscriber)
    @subscriber = subscriber
    @newsletter = newsletter
    mail to: subscriber.email, subject: newsletter.subject
  end
end
