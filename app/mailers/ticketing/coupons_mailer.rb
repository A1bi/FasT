# frozen_string_literal: true

module Ticketing
  class CouponsMailer < ApplicationMailer
    layout 'mailer'

    def coupon(coupon, email:, subject:, body:, recipient:)
      @body = body
      @coupon = coupon
      @recipient = recipient
      @skip_ending = true

      mail to: email, subject:
    end
  end
end
