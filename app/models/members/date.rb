# frozen_string_literal: true

module Members
  class Date < ApplicationRecord
    validates :datetime, presence: true

    def self.not_expired
      where('datetime > ?', 2.hours.ago)
    end
  end
end
