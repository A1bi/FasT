class ContactMessageMailer < BaseMailer
  default to: Settings.contact_messages.mail_to,
          reply_to: nil,
          return_path: default[:from]

  def contact_message(name, email, phone, subject, content)
    @name = name
    @email = email
    @phone = phone
    @content = content

    mail from: "#{name}<#{email}>", subject: "#{subject} (#{t('contact_messages.via')})"
  end
end
