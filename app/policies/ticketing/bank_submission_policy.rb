# frozen_string_literal: true

module Ticketing
  class BankSubmissionPolicy < ApplicationPolicy
    def create?
      !Settings.ebics.enabled && user_admin?
    end

    def file?
      create?
    end
  end
end
