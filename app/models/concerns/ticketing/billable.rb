# frozen_string_literal: true

module Ticketing
  module Billable
    extend ActiveSupport::Concern

    included do
      has_one :billing_account,
              as: :billable, inverse_of: :billable,
              class_name: 'Ticketing::Billing::Account', dependent: :destroy

      after_initialize :build_billing_account, if: :new_record?
    end

    def withdraw_from_account(amount, note_key)
      billing_account.withdraw(amount, note_key)
    end

    def deposit_into_account(amount, note_key)
      billing_account.deposit(amount, note_key)
    end

    def transfer_to_account(recipient, amount, note_key)
      billing_account.transfer(recipient.billing_account, amount, note_key)
    end
  end
end
