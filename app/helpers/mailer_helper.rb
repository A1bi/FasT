module MailerHelper
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

  def render_inline(template, options = {})
    # remove final newline from partial
    # so it will not add whitespace to mail content
    # or even line breaks in text mails

    # rubocop:disable Rails/OutputSafety
    render(template, options).chomp.html_safe
    # rubocop:enable Rails/OutputSafety
  end
end
