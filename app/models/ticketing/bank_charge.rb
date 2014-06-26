module Ticketing
  class BankCharge < BaseModel
    belongs_to :submission, class_name: BankSubmission
    belongs_to :chargeable, polymorphic: true, touch: true
    
    validates_presence_of :name
    validates :amount, numericality: { greater_than: 0 }
    validates_with SEPA::IBANValidator
    
    def mandate_id
      id
    end
    
    def iban=(val)
      super(strip_number(val))
    end
    
    def amount=(val)
      return if submission.present?
      super
    end
    
    private
    
    def strip_number(number)
      number.gsub(/ /, "").upcase
    end
  end
end
