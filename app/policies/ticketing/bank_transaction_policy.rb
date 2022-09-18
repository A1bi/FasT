# frozen_string_literal: true

module Ticketing
  class BankTransactionPolicy < ApplicationPolicy
    def submit?
      user_admin?
    end
  end
end
