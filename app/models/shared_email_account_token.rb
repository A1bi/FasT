# frozen_string_literal: true

class SharedEmailAccountToken < ApplicationRecord
  validates :email, presence: true
end
