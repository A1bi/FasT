module Ticketing
  class BankCharge < BaseModel
    belongs_to :submission, class_name: BankSubmission
    belongs_to :chargeable, polymorphic: true, :touch => true
    
    validates_presence_of :name, :number, :blz, :bank
    validates_format_of :number, :with => /\A\d{1,12}\z/
    validates_format_of :blz, :with => /\A\d{8}\z/
  end
end
