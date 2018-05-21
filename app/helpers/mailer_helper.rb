module MailerHelper
  def attached_image_tag(filename)
    name = "inline_#{filename}"
    attachments.inline[name] = File.read("#{Rails.root}/public/images/mail/#{filename}")
    image_tag attachments[name].url
  end
end
