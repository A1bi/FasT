class NewsletterMailer < BaseMailer
  def subscribed(subscriber)
    @subscriber = subscriber
    mail to: subscriber.email
  end
end
