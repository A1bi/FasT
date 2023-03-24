# frozen_string_literal: true

module Ticketing
  module Web
    class Order < Ticketing::Order
      include Anonymizable

      PAYMENT_DUE_AFTER = 1.week
      PAYMENT_OVERDUE_AFTER = 2.weeks

      enum :pay_method, %i[charge transfer cash box_office], suffix: :payment
      belongs_to :geolocation, foreign_key: :plz, primary_key: :postcode, inverse_of: false, optional: true

      auto_strip_attributes :first_name, :last_name, :affiliation, squish: true
      phony_normalize :phone, default_country_code: 'DE'
      is_anonymizable columns: %i[email first_name last_name gender affiliation phone]

      validates :email, :gender, :first_name, :last_name, :plz, presence: { on: :unprivileged_order }
      validates :gender, inclusion: { in: 0..1, allow_blank: true }
      validates :plz, format: { with: /\A\d{5}\z/, allow_blank: true }
      validates :email, allow_blank: true, email_format: true
      validates :pay_method, presence: { if: proc { |order| !order.paid } }

      after_save :schedule_geolocation

      def due?
        !paid? && transfer_payment? && PAYMENT_DUE_AFTER.after(created_at).past?
      end

      def overdue?
        due? && PAYMENT_OVERDUE_AFTER.after(created_at).past?
      end

      def update_total
        old_total = total
        super

        # set default pay method when a free order (without a pay method set) turns into a non-free order
        self.pay_method = :cash if pay_method.blank? && old_total.zero? && total.positive?

        total
      end

      private

      def schedule_geolocation
        return unless saved_change_to_plz? && geolocation.blank?

        Ticketing::GeolocatePostcodeJob.perform_later(plz)
      end
    end
  end
end
