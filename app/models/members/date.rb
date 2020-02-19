module Members
  class Date < BaseModel
    validates :datetime, presence: true

    def self.not_expired
      where('datetime > ?', 2.hours.ago)
    end
  end
end
