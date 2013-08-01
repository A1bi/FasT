module Ticketing
  class BankCharge < ActiveRecord::Base
    attr_accessible :bank, :blz, :name, :number
    
    belongs_to :submission, class_name: BankSubmission
    belongs_to :chargeable, polymorphic: true
    
    validates_presence_of :name, :number, :blz, :bank
    validates_format_of :number, :with => /^\d{1,12}$/
    validates_format_of :blz, :with => /^\d{8}$/
  end
end
