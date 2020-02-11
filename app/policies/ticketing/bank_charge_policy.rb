module Ticketing
  class BankChargePolicy < ApplicationPolicy
    def approve?
      user_admin?
    end

    def submit?
      user_admin?
    end

    def submission_file?
      user_admin?
    end
  end
end
