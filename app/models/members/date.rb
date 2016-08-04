class Members::Date < BaseModel
  validates_presence_of :datetime

  def self.not_expired
    where("datetime > ?", Time.zone.now - 2.hours)
  end
end
