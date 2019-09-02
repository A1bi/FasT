module Ticketing
  class OrderPolicy < ApplicationPolicy
    def mark_as_paid?
      current_user_admin?
    end

    def credit_transfer_file?
      current_user_admin?
    end
  end
end
