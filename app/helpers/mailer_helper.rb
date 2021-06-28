# frozen_string_literal: true

module MailerHelper
  include RenderHelper

  def attached_image_tag(filename, options = {})
    name = "inline_#{filename}"

    attachments.inline[name] = File.read(
      "#{Rails.root}/public/images/mail/#{filename}"
    )

    options[:style] = "height:#{options[:height]}px;width:auto" if options[:height]

    image_tag attachments[name].url, options
  end

  def number_to_currency(number, options = {})
    # fix -amount to return '-0.00' when amount is zero
    super(number.zero? ? 0 : number, options)
  end
end
