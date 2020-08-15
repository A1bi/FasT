# frozen_string_literal: true

class SharedEmailAccountTokensCleanupJob < ApplicationJob
  def perform
    SharedEmailAccountToken.expired.each(&:destroy!)
  end
end
