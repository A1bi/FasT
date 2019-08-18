class ContactMessagesController < ApplicationController
  before_action :filter_spam, only: :create

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

  def filter_spam
    return if params[:comment].blank?

    Raven.capture_message('rejected spam message')
    redirect_to contact_messages_path
  end

  def message_params
    params.require(:contact_message).permit(
      :name, :email, :phone, :subject, :content
    )
  end
end
