# frozen_string_literal: true

module Ticketing
  module Web
    class Order < Ticketing::Order
      include Anonymizable

      enum pay_method: %i[charge transfer cash box_office], _suffix: :payment
      has_one :bank_charge, class_name: 'Ticketing::BankCharge',
                            as: :chargeable, validate: true,
                            dependent: :destroy, autosave: true
      belongs_to :geolocation, foreign_key: :plz, primary_key: :postcode,
                               inverse_of: false, optional: true

      auto_strip_attributes :first_name, :last_name, :affiliation, squish: true
      phony_normalize :phone, default_country_code: 'DE'
      is_anonymizable columns: %i[email first_name last_name gender affiliation
                                  phone]

      validates :email, :gender, :first_name, :last_name, :plz,
                presence: { on: :unprivileged_order }
      validates :gender, inclusion: { in: 0..1, allow_blank: true }
      validates :plz, format: { with: /\A\d{5}\z/, allow_blank: true }
      validates :email, allow_blank: true, email_format: true
      validates :pay_method, presence: { if: proc { |order| !order.paid } }

      after_create { send_confirmation(after_commit: true) }
      after_save :schedule_geolocation
      after_commit :send_queued_mails

      def self.charges_to_submit(approved)
        charge_payment
          .includes(:billing_account, :bank_charge)
          .where('ticketing_billing_accounts.balance < 0')
          .where(ticketing_bank_charges: { approved: approved,
                                           submission_id: nil })
      end

      def resend_items
        enqueue_mailing(:resend_items)
        log(:resent_items)
      end

      def send_confirmation(after_commit: false, log: false)
        enqueue_mailing(:confirmation, depends_on_commit: after_commit)
        self.log(:resent_confirmation) if log
      end

      def approve
        return unless bank_charge

        bank_charge.approved = true
        log(:approved)
      end

      def bank_charge_submitted
        bank_charge.amount = -billing_account.balance
        withdraw_from_account(billing_account.balance, :bank_charge_submitted)
        log(:charge_submitted)
      end

      def enqueue_mailing(action, params: {}, depends_on_commit: false)
        return if email.blank?

        params[:order] = self
        mail = Ticketing::OrderMailer.with(params).public_send(action)

        if depends_on_commit
          (@queued_mails ||= []) << mail
        else
          mail.deliver_later
        end
      end

      def update_total_and_billing(billing_note)
        old_total = total
        super
        return unless pay_method.blank? && old_total.zero? && total.positive?

        # set default pay method when a free order (without a pay method set)
        # turns into a non-free order
        self.pay_method = :cash
      end

      private

      def schedule_geolocation
        return unless saved_change_to_plz? && geolocation.blank?

        Ticketing::GeolocatePostcodeJob.perform_later(plz)
      end

      def send_queued_mails
        @queued_mails&.each do |mail|
          mail.deliver_later
        end
      end

      def update_paid
        super
        self.paid ||= bank_charge.present? && !bank_charge.submitted?
      end
    end
  end
end
