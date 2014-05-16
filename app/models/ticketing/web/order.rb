module Ticketing
  class Web::Order < Order    
    attr_accessor :admin_validations
	
    has_one :bank_charge, class: Ticketing::BankCharge, as: :chargeable, validate: true, dependent: :destroy
    enum pay_method: [:charge, :transfer, :cash]
  
    validates_presence_of :email, :first_name, :last_name, :phone, :plz, if: Proc.new { |order| !order.admin_validations }
    validates_inclusion_of :gender, in: 0..1, if: Proc.new { |order| !order.admin_validations }
    validates_format_of :plz, with: /\A\d{5}\z/, if: Proc.new { |order| !order.admin_validations }
    validates :email, allow_blank: true, email_format: true
    validates_presence_of :pay_method, if: Proc.new { |order| order.total > 0 }
  
    before_validation :before_validation, on: :create
    after_create :send_confirmation
    
    def send_pay_reminder
      OrderMailer.pay_reminder(self).deliver
      log(:sent_pay_reminder)
    end
    
    def resend_tickets
      OrderMailer.resend_tickets(self).deliver
      log(:resent_tickets)
    end
    
    def send_confirmation
      OrderMailer.confirmation(self).deliver
    end
    
    def approve
      return if !bank_charge
      bank_charge.approved = true
      bank_charge.save
      log(:approved)
    end
    
    def mark_as_paid
      super
      OrderMailer.payment_received(self).deliver
    end
    
    def api_hash(detailed = false)
      super(detailed).merge({
        first_name: first_name,
        last_name: last_name
      })
    end
    
    def total=(t)
      super
      update_charge_amount
    end
    
    private
    
    def before_validation
      if charge?
        self.paid = true
        update_charge_amount
      end
    end
    
    def update_charge_amount
      bank_charge.amount = total if bank_charge.present?
    end
  end
end