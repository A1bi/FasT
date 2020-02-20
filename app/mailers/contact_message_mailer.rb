class ContactMessageMailer < ApplicationMailer
  default to: Settings.contact_messages.mail_to,
          reply_to: nil,
          return_path: default[:from]

  rescue_from Net::SMTPFatalError, with: :log_spam_rejection

  def contact_message(name, email, phone, subject, content)
    @name = name
    @email = email
    @phone = phone
    @content = content

    mail from: "#{name}<#{email}>",
         subject: "#{subject} (#{t('contact_messages.via')})"
  end

  private

  def log_spam_rejection(exception)
    raise unless exception.message.downcase.include? 'spam'

    Rails.logger.info "Message with subject '#{message.subject}'" \
                      'rejected as spam by MTA'
  end
end
