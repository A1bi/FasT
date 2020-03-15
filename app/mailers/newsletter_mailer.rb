# frozen_string_literal: true

class NewsletterMailer < ApplicationMailer
  before_action :set_subscriber

  default to: -> { @subscriber.email }

  def confirmation_instructions
    @after_order = params[:after_order]
    @skip_unsubscribe_link = true
    mail
  end

  def newsletter
    @newsletter = params[:newsletter]

    headers['List-Unsubscribe'] = unsubscribe_address

    mail subject: @newsletter.subject
  end

  private

  def set_subscriber
    @subscriber = if params[:subscriber].present?
                    params[:subscriber]
                  elsif params[:email]
                    Newsletter::Subscriber.new(email: params[:email])
                  end
  end

  def unsubscribe_address
    "<mailto:unsubscribe+#{@subscriber.token}@theater-kaisersesch.de>"
  end
end
