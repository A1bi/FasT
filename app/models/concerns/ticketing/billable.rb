module Ticketing
  module Billable
    extend ActiveSupport::Concern

    included do
      has_one :billing_account,
              as: :billable, inverse_of: :billable, autosave: true,
              class_name: Ticketing::Billing::Account
    end

    def billing_account
      super || build_billing_account
    end

    private

    def transfer_to_account(recipient, amount)
      billing_account.transfer(recipient.billing_account, amount)
    end
  end
end
