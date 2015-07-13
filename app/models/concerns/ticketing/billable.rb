module Ticketing
  module Billable
    extend ActiveSupport::Concern

    included do
      has_one :billing_account,
              as: :billable, inverse_of: :billable, autosave: true,
              class_name: Ticketing::Billing::Account, dependent: :destroy
    end

    def billing_account
      super || build_billing_account
    end
    
    def api_hash(details = [])
      hash = defined?(super) ? super : {}
      hash.merge!({
        balance: billing_account.balance
      }) if details.include? :billing
      hash
    end

    private

    def after_account_transfer
    end

    def withdraw_from_account(amount, note_key)
      billing_account.withdraw(amount, note_key)
      after_account_transfer
    end

    def deposit_into_account(amount, note_key)
      billing_account.deposit(amount, note_key)
      after_account_transfer
    end

    def transfer_to_account(recipient, amount, note_key)
      billing_account.transfer(recipient.billing_account, amount, note_key)
      after_account_transfer
    end
  end
end
