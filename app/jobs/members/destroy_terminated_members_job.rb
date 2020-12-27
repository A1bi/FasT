# frozen_string_literal: true

module Members
  class DestroyTerminatedMembersJob < ApplicationJob
    def perform
      Member.membership_terminated.destroy_all
    end
  end
end
