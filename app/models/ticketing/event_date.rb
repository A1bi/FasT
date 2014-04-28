class Ticketing::EventDate < BaseModel
  belongs_to :event, :touch => true
	has_many :reservations, :foreign_key => "date_id"
  
  def current?
    date === self.class.current_range
  end
  
  def self.upcoming
    where(date: self.class.current_range).first || first
  end
  
  private
  
  def self.current_range
    Time.zone.now.beginning_of_day..Time.zone.now.tomorrow.beginning_of_day
  end
end
