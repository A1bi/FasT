# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  helper :mailer

  def mail(options)
    options[:to] = if Rails.env.development?
                     Settings.action_mailer.mail_to_in_development
                   else
                     options[:to] || self.class.default[:to]
                   end

    if options[:to].present?
      parts = options[:to].split('@')
      unless parts[1].ascii_only?
        parts[1] = SimpleIDN.to_ascii(parts[1])
        options[:to] = parts.join('@')
      end
    end

    super

    fix_mixed_attachments
  end

  # fix regular attachments not showing up in some clients when
  # sending inline attachments
  # source: https://github.com/rails/rails/issues/2686#issuecomment-20186734
  def fix_mixed_attachments
    # do nothing if we have no actual attachments
    return if @_message.parts.select { |p| p.attachment? && !p.inline? }.none?

    mail = Mail.new

    related = Mail::Part.new
    related.content_type = @_message.content_type
    @_message.parts.select { |p| !p.attachment? || p.inline? }
             .each { |p| related.add_part(p) }
    mail.add_part related

    mail.header = @_message.header.to_s
    mail.content_type = nil
    @_message.parts.select { |p| p.attachment? && !p.inline? }
             .each { |p| mail.add_part(p) }

    @_message = mail
    wrap_delivery_behavior!(delivery_method.to_sym)
  end
end
