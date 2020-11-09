# frozen_string_literal: true

module Ticketing
  module Billing
    class Transfer < ApplicationRecord
      belongs_to :account
      belongs_to :participant, class_name: 'Account', optional: true,
                               autosave: true
      belongs_to :reverse_transfer, class_name: 'Transfer', optional: true

      validates :amount, numericality: true
    end
  end
end
