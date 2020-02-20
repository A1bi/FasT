class NewsletterMailer < ApplicationMailer
  def confirmation_instructions(subscriber, after_order: false)
    @subscriber = subscriber
    @after_order = after_order
    @skip_unsubscribe_link = true
    mail to: subscriber.email
  end

  def newsletter(newsletter, subscriber)
    @subscriber = subscriber
    @newsletter = newsletter

    headers['List-Unsubscribe'] = unsubscribe_address

    mail to: subscriber.email, subject: newsletter.subject do |format|
      format.text { @newsletter.body_text_final }
      format.html { @newsletter.body_html_final }
    end
  end

  private

  def unsubscribe_address
    "<mailto:unsubscribe+#{@subscriber.token}@theater-kaisersesch.de>"
  end
end
