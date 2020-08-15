# frozen_string_literal: true

class SharedEmailAccountToken < ApplicationRecord
  EXPIRES_AFTER = 5.minutes

  validates :email, presence: true

  def expired?
    (created_at + EXPIRES_AFTER).past?
  end
end
