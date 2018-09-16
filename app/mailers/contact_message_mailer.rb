class ContactMessageMailer < BaseMailer
  default to: 'info@theater-kaisersesch.de',
          reply_to: nil,
          return_path: 'noreply@theater-kaisersesch.de'

  def contact_message(name, email, phone, subject, content)
    @name = name
    @email = email
    @phone = phone
    @content = content

    mail from: "#{name}<#{email}>", subject: "#{subject} (#{t('contact_messages.via')})"
  end
end
