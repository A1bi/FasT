# frozen_string_literal: true

class NewsletterMailer < ApplicationMailer
  before_action { @subscriber = params[:subscriber] }

  default to: -> { @subscriber.email }

  def confirmation_instructions
    @after_order = params[:after_order]
    @skip_unsubscribe_link = true
    mail
  end

  def newsletter
    @newsletter = params[:newsletter]

    headers['List-Unsubscribe'] = unsubscribe_address

    mail subject: @newsletter.subject do |format|
      format.text { @newsletter.body_text_final }
      format.html { @newsletter.body_html_final }
    end
  end

  private

  def unsubscribe_address
    "<mailto:unsubscribe+#{@subscriber.token}@theater-kaisersesch.de>"
  end
end
