module Ticketing
  class BankCharge < ActiveRecord::Base
    attr_accessible :bank, :blz, :name, :number
    
    belongs_to :submission, class_name: BankSubmission
    belongs_to :chargeable, polymorphic: true
  end
end
