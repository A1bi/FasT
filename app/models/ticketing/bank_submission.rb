module Ticketing
  class BankSubmission < BaseModel
    has_many :charges,
            class_name: BankCharge, foreign_key: :submission_id,
            dependent: :nullify, autosave: true, after_add: :propagate_submission

    validates_length_of :charges, minimum: 1
    
    private

    def propagate_submission(charge)
      charge.chargeable.bank_charge_submitted
    end
  end
end
