# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  helper :application, :mailer

  def mail(options = {})
    options[:to] = prepare_recipient_email(options[:to])
    return if options[:to].blank?

    super
  end

  private

  def prepare_recipient_email(email)
    if Rails.env.development? &&
       Settings.action_mailer.mail_to_in_development.present?
      email = Settings.action_mailer.mail_to_in_development
    else
      email ||= compute_default(self.class.default[:to])
    end
    return if email.blank?

    # convert to punycode for domains with non-ascii characters
    parts = email.split('@')
    return email if parts[1].ascii_only?

    parts[1] = SimpleIDN.to_ascii(parts[1])
    parts.join('@')
  end
end
