module Ticketing::Billing
  class Transfer < BaseModel
    belongs_to :account
    belongs_to :participant, class_name: 'Account', autosave: true
    belongs_to :reverse_transfer, class_name: 'Transfer'

    validates_presence_of :account
    validates_numericality_of :amount

    def note_key
      super.to_sym
    end
  end
end
