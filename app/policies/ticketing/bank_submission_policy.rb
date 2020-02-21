module Ticketing
  class BankSubmissionPolicy < ApplicationPolicy
    def submission_file?
      user_admin?
    end
  end
end
