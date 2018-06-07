module Ticketing
  class CouponsMailer < BaseMailer
    layout 'mailer'

    def coupon(coupon, email:, subject:, body:, recipient:)
      @body = body
      @coupon = coupon
      @recipient = recipient
      @skip_ending = true

      mail to: email, subject: subject if email.present?
    end
  end
end
