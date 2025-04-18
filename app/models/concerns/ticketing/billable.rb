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

    class_methods do
      def with_debt
        joins(:billing_account).merge(Billing::Account.debt)
      end

      def with_credit
        joins(:billing_account).merge(Billing::Account.credit)
      end

      def balance_sum
        joins(:billing_account).sum('ticketing_billing_accounts.balance')
      end
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
