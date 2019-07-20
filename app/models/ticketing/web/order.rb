module Ticketing
  class Web::Order < Order
    attr_accessor :admin_validations

    has_one :bank_charge, class_name: 'Ticketing::BankCharge', as: :chargeable, validate: true, dependent: :destroy, autosave: true
    enum pay_method: [:charge, :transfer, :cash, :box_office], _suffix: :payment

    auto_strip_attributes :first_name, :last_name, squish: true
    phony_normalize :phone, default_country_code: 'DE'

    validates_presence_of :email, :first_name, :last_name, :plz, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates_inclusion_of :gender, in: 0..1, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates_format_of :plz, with: /\A\d{5}\z/, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates :email, allow_blank: true, email_format: true
    validates_presence_of :pay_method, if: Proc.new { |order| !order.paid }

    after_create { send_confirmation(after_commit: true) }
    after_commit :send_queued_mails

    def self.charges_to_submit(approved)
      charge_payment
        .includes(:billing_account, :bank_charge)
        .where("ticketing_billing_accounts.balance < 0")
        .where(ticketing_bank_charges: { approved: approved, submission_id: nil })
    end

    def send_pay_reminder
      enqueue_mailing(:pay_reminder)
      log(:sent_pay_reminder)
    end

    def resend_tickets
      enqueue_mailing(:resend_tickets)
      log(:resent_tickets)
    end

    def send_confirmation(after_commit: false, log: false)
      enqueue_mailing(:confirmation, depends_on_commit: after_commit)
      self.log(:resent_confirmation) if log
    end

    def approve
      return if !bank_charge
      bank_charge.approved = true
      log(:approved)
    end

    def mark_as_paid
      super
      enqueue_mailing(:payment_received, depends_on_commit: true)
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

    def enqueue_mailing(action, options = nil)
      return if email.blank?

      mail = Ticketing::OrderMailer.order_action(action.to_s, self, options)

      if options&.delete(:depends_on_commit)
        (@queued_mails ||= []) << mail
      else
        mail.deliver_later
      end
    end

    def update_total_and_billing(billing_note)
      old_total = total
      super
      # set default pay method when a free order (without a pay method set) turns into a non-free order
      self.pay_method = :cash if pay_method.blank? && old_total.zero? && total.positive?
    end

    private

    def send_queued_mails
      @queued_mails&.each do |mail|
        mail.deliver_later
      end
    end

    def update_paid
      super
      self.paid = self.paid || (bank_charge.present? && !bank_charge.submitted?)
    end
  end
end
