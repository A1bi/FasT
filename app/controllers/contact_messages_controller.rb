# frozen_string_literal: true

class ContactMessagesController < ApplicationController
  include SpamFiltering

  skip_authorization

  filters_spam_through_honeypot only: :create
  filters_spam_in_param proc { |params| params[:contact_message][:name] }, max_length: 50, only: :create

  def index
    @message = ContactMessage.new
  end

  def create
    @message = ContactMessage.new(message_params)

    if @message.mail
      redirect_to contact_messages_path, notice: t('.success')
    else
      render action: :index
    end
  end

  private

  def message_params
    params.expect(contact_message: %i[name email phone subject content])
  end
end
