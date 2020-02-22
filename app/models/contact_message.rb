# frozen_string_literal: true

class ContactMessage
  include ActiveModel::Model

  attr_accessor :name, :email, :phone, :subject, :content

  validates :name, :email, :subject, :content, presence: true
  validates :email, email_format: true

  def mail
    return false unless valid?

    ContactMessageMailer.contact_message(name, email, phone, subject, content)
                        .deliver_later
    true
  end
end
