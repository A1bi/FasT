# frozen_string_literal: true

module Ticketing
  class BankRefundSubmissionPolicy < ApplicationPolicy
    def submission_file?
      user_admin?
    end
  end
end
