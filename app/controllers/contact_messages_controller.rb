class ContactMessagesController < ApplicationController
  def index
    @message = ContactMessage.new
  end

  def create
    @message = ContactMessage.new(message_params)

    if @message.mail
      redirect_to contact_messages_path, notice: t('contact_messages.success')
    else
      render action: :index
    end
  end

  private

  def message_params
    params.require(:contact_message).permit(:name, :email, :phone, :content)
  end
end
