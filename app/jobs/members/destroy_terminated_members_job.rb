# frozen_string_literal: true

module Members
  class DestroyTerminatedMembersJob < ApplicationJob
    def perform
      terminated_members.destroy_all
    end

    private

    def terminated_members
      Member.where('membership_terminates_on < ?', Time.current)
    end
  end
end
