module Ticketing
  class Web::Order < Order
    attr_accessor :admin_validations

    has_one :bank_charge, class_name: Ticketing::BankCharge, as: :chargeable, validate: true, dependent: :destroy, autosave: true
    enum pay_method: [:charge, :transfer, :cash]

    auto_strip_attributes :first_name, :last_name, squish: true
    phony_normalize :phone, default_country_code: 'DE'

    validates_presence_of :email, :first_name, :last_name, :plz, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates_inclusion_of :gender, in: 0..1, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates_format_of :plz, with: /\A\d{5}\z/, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates :email, allow_blank: true, email_format: true
    validates_presence_of :pay_method, if: Proc.new { |order| !order.paid }

    after_create_commit :send_confirmation

    def send_pay_reminder
      enqueue_mailing(:pay_reminder)
      log(:sent_pay_reminder)
    end

    def resend_tickets
      enqueue_mailing(:resend_tickets)
      log(:resent_tickets)
    end

    def send_confirmation
      enqueue_mailing(:confirmation)
    end

    def cancel_tickets(tickets, reason)
      super
      enqueue_mailing(:cancellation, reason: reason)
    end

    def approve
      return if !bank_charge
      bank_charge.approved = true
      log(:approved)
    end

    def mark_as_paid
      super
      enqueue_mailing(:payment_received)
    end

    def api_hash(details = [], ticket_details = [])
      hash = super
      hash.merge!({
        first_name: first_name,
        last_name: last_name
      }) if details.include? :personal
      hash
    end

    def bank_charge_submitted
      bank_charge.amount = -billing_account.balance
      withdraw_from_account(billing_account.balance, :bank_charge_submitted)
      log(:charge_submitted)
    end

    private

    def enqueue_mailing(action, options = nil)
      Resque.enqueue(Mailer, id, action, options) if email.present?
    end
  end
end
