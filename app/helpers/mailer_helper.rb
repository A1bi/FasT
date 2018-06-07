module MailerHelper
  def attached_image_tag(filename)
    name = "inline_#{filename}"
    attachments.inline[name] = File.read("#{Rails.root}/public/images/mail/#{filename}")
    image_tag attachments[name].url
  end

  def render_inline(template, options = {})
    # remove final newline from partial
    # so it will not add whitespace to mail content or even line breaks in text mails
    render(template, options).chomp.html_safe
  end
end
