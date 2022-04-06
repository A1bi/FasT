# frozen_string_literal: true

module Ticketing
  module CouponsMailerHelper
    def prepare_body(body, coupon:, recipient:, html: false)
      body = insert_recipient(body, recipient)
      body = insert_code(body, coupon, html:)
      return body unless html

      simple_format(body)
    end

    def insert_code(body, coupon, html:)
      code = html ? tag.span(coupon.code, class: 'coupon-code') : coupon.code
      body.gsub('%%code%%', code)
    end

    def insert_recipient(body, recipient)
      body.gsub('%%recipient%%', recipient)
    end
  end
end
