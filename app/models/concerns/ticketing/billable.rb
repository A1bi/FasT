module Ticketing
  module Billable
    extend ActiveSupport::Concern

    included do
      has_one :billing_account, as: :billable, class_name: Ticketing::Billing::Account, autosave: true
      before_create :build_billing_account
    end

    private

    def transfer(recipient, amount)
      billing_account.transfer(recipient.billing_account, amount)
    end
  end
end
