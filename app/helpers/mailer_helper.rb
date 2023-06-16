# frozen_string_literal: true

module MailerHelper
  include RenderHelper

  def number_to_currency(number, options = {})
    # fix -amount to return '-0.00' when amount is zero
    super(number.zero? ? 0 : number, options)
  end
end
