module Ticketing
  class Web::Order < Order    
    attr_accessor :admin_validations
	
    has_one :bank_charge, class: Ticketing::BankCharge, as: :chargeable, validate: true, dependent: :destroy, autosave: true
    enum pay_method: [:charge, :transfer, :cash]
  
    validates_presence_of :email, :first_name, :last_name, :phone, :plz, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates_inclusion_of :gender, in: 0..1, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates_format_of :plz, with: /\A\d{5}\z/, if: Proc.new { |order| !order.admin_validations }, on: :create
    validates :email, allow_blank: true, email_format: true
    validates_presence_of :pay_method, if: Proc.new { |order| order.total > 0 }
    
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
    
    def approve
      return if !bank_charge
      bank_charge.approved = true
      log(:approved)
    end

    def mark_as_paid
      super
      enqueue_mailing(:payment_received) if transfer?
    end
    
    def api_hash(details = [], ticket_details = [])
      hash = super
      hash.merge!({
        first_name: first_name,
        last_name: last_name
      }) if details.include? :personal
      hash
    end
    
    def total=(t)
      super
      update_charge_amount
    end
    
    def updated_tickets(t = nil)
      super
      (t || tickets).each do |ticket|
        ticket.update_passbook_pass
      end
    end

    private

    def update_charge_amount
      bank_charge.amount = total if bank_charge.present?
    end
    
    def enqueue_mailing(action)
      Resque.enqueue(Mailer, id, action)
    end
  end
end