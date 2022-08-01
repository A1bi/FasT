# frozen_string_literal: true

module Ticketing
  class BankRefundPolicy < ApplicationPolicy
    def submit?
      user_admin?
    end
  end
end
