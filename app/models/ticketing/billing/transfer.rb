module Ticketing
  module Billing
    class Transfer < ApplicationRecord
      belongs_to :account
      belongs_to :participant, class_name: 'Account', optional: true,
                               autosave: true
      belongs_to :reverse_transfer, class_name: 'Transfer', optional: true

      validates :amount, numericality: true

      def note_key
        super.to_sym
      end
    end
  end
end
