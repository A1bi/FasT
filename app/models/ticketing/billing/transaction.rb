# frozen_string_literal: true

module Ticketing
  module Billing
    class Transaction < ApplicationRecord
      belongs_to :account
      belongs_to :participant, class_name: 'Account', optional: true
      belongs_to :reverse_transaction, class_name: 'Transaction', optional: true

      validates :amount, numericality: true
    end
  end
end
