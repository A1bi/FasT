module NewsletterMailerHelper
  def insert_confirmation_url(content)
    url = confirm_newsletter_subscriber_url(token: @subscriber.token)
    content.gsub(/%%confirmation_url%%/, url)
  end
end
