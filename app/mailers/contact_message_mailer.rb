class ContactMessageMailer < BaseMailer
  def contact_message(name, email, phone, content)
    @name = name
    @email = email
    @phone = phone
    @content = content
    mail to: 'info@theater-kaisersesch.de'
  end
end
