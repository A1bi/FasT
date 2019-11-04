module MailerHelper
  include RenderHelper

  def attached_image_tag(filename, options = {})
    name = "inline_#{filename}"

    attachments.inline[name] = File.read(
      "#{Rails.root}/public/images/mail/#{filename}"
    )

    if options[:height]
      options[:style] = "height:#{options[:height]}px;width:auto"
    end

    image_tag attachments[name].url, options
  end
end
