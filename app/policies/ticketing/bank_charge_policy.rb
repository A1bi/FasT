# frozen_string_literal: true

module Ticketing
  class BankChargePolicy < ApplicationPolicy
    def submit?
      user_admin?
    end
  end
end
