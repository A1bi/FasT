# frozen_string_literal: true

module Ticketing
  class BankChargePolicy < ApplicationPolicy
    def approve?
      user_admin?
    end

    def submit?
      user_admin?
    end
  end
end
