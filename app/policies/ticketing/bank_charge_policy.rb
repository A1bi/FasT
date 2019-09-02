module Ticketing
  class BankChargePolicy < ApplicationPolicy
    def approve?
      current_user_admin?
    end

    def submit?
      current_user_admin?
    end

    def submission_file?
      current_user_admin?
    end
  end
end
