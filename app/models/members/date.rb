class Members::Date < BaseModel
  validates_presence_of :datetime

  def self.not_expired
    where('datetime > ?', 2.hours.ago)
  end
end
