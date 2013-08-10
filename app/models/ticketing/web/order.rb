module Ticketing
  class Web::Order < ActiveRecord::Base
    include Orderable
  
    attr_accessible :email, :first_name, :gender, :last_name, :phone, :plz
    attr_accessor :service_validations
	
    has_one :bank_charge, :as => :chargeable, :validate => true, dependent: :destroy
  
    validates_presence_of :email, :first_name, :last_name, :phone, :plz, if: Proc.new { |order| !order.service_validations }
    validates_inclusion_of :gender, :in => 0..1, if: Proc.new { |order| !order.service_validations }
    validates_format_of :plz, :with => /^\d{5}$/, if: Proc.new { |order| !order.service_validations }
    validates :email, :allow_blank => true, :email_format => true
    validates_inclusion_of :pay_method, :in => ["charge", "transfer"]
  
    before_validation :before_validation, on: :create
    after_create :send_confirmation
    
    def send_pay_reminder
      OrderMailer.pay_reminder(self).deliver
      bunch.log(:sent_pay_reminder)
    end
    
    def send_confirmation
      OrderMailer.confirmation(self).deliver
    end
    
    def approve
      return if !bank_charge
      bank_charge.approved = true
      bank_charge.save
      bunch.log(:approved)
    end
    
    private
    
    def before_validation
      if bunch.total.zero?
        self.pay_method = "transfer"
      elsif pay_method == "charge"
        bunch.paid = true
      end
    end
  end
end