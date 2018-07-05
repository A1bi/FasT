class ContactMessage
  include ActiveModel::Model

  attr_accessor :name, :email, :phone, :content

  validates :name, :email, :content, presence: true
  validates :email, email_format: true

  def mail
    return false unless valid?
    ContactMessageMailer.contact_message(self.name, email, phone, content).deliver_later
    true
  end
end
