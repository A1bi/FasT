# frozen_string_literal: true

module Ticketing
  module Web
    class Order < Ticketing::Order
      PAYMENT_DUE_AFTER = 1.week
      PAYMENT_OVERDUE_AFTER = 2.weeks

      enum :pay_method, %i[charge transfer cash box_office stripe], suffix: :payment
      belongs_to :geolocation, foreign_key: :plz, primary_key: :postcode, inverse_of: false, optional: true
      has_many :stripe_transactions, dependent: :destroy

      auto_strip_attributes :first_name, :last_name, :affiliation, squish: true
      phony_normalize :phone, default_country_code: 'DE'
      is_anonymizable columns: %i[email first_name last_name gender affiliation phone]

      validates :email, :gender, :first_name, :last_name, :plz, presence: { on: :unprivileged_order }
      validates :gender, inclusion: { in: 0..1, allow_blank: true }
      validates :plz, plz_format: true, allow_blank: true
      validates :email, email_format: true, allow_blank: true
      validates :pay_method, presence: { if: proc { |order| !order.paid } },
                             exclusion: { in: %w[stripe], on: :create, unless: proc { Settings.stripe.enabled } }

      after_save :schedule_geolocation

      def stripe_payment
        stripe_transactions.payments.first
      end

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
