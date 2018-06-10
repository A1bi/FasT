class BaseMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  helper :mailer

  default I18n.t("action_mailer.defaults")

  def mail(options)
    if Rails.env.development?
      options[:to] = 'albo@a0s.de'
    else
      parts = options[:to].split('@')
      unless parts[1].ascii_only?
        parts[1] = SimpleIDN.to_ascii(parts[1])
        options[:to] = parts.join('@')
      end
    end

    super

    fix_mixed_attachments
  end

  # fix regular attachments not showing up in some clients when sending inline attachments
  # source: https://github.com/rails/rails/issues/2686#issuecomment-20186734
  def fix_mixed_attachments
    # do nothing if we have no actual attachments
    return if @_message.parts.select { |p| p.attachment? && !p.inline? }.none?

    mail = Mail.new

    related = Mail::Part.new
    related.content_type = @_message.content_type
    @_message.parts.select { |p| !p.attachment? || p.inline? }.each { |p| related.add_part(p) }
    mail.add_part related

    mail.header = @_message.header.to_s
    mail.content_type = nil
    @_message.parts.select { |p| p.attachment? && !p.inline? }.each { |p| mail.add_part(p) }

    @_message = mail
    wrap_delivery_behavior!(delivery_method.to_sym)
  end
end
