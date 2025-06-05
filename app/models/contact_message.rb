# frozen_string_literal: true

class ContactMessage
  include ActiveModel::Model

  attr_accessor :name, :email, :phone, :subject, :content

  validates :name, :subject, :content, presence: true
  validates :email, email_format: true

  def mail
    ContactMessageMailer.contact_message(name, email, phone, subject, content).deliver_later if valid?
  end
end
