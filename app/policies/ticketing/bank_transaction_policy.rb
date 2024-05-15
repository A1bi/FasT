# frozen_string_literal: true

module Ticketing
  class BankTransactionPolicy < ApplicationPolicy
    def submit?
      !Settings.ebics.enabled && user_admin?
    end
  end
end
