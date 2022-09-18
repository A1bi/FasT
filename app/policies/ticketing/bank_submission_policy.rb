# frozen_string_literal: true

module Ticketing
  class BankSubmissionPolicy < ApplicationPolicy
    def file?
      user_admin?
    end
  end
end
