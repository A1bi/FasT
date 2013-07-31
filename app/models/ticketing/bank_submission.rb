module Ticketing
  class BankSubmission < ActiveRecord::Base
    has_many :charges, class_name: BankCharge, :foreign_key => "submission_id", dependent: :nullify, after_add: :log_submission
  
    validates_length_of :charges, :minimum => 1
    
    private
    
    def log_submission(charge)
      charge.chargeable.bunch.log(:charge_submitted) if charge.chargeable.is_a? Web::Order
    end
  end
end
