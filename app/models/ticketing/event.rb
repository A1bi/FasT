module Ticketing
  class Event < BaseModel
    has_many :dates, class_name: EventDate
  
    def self.by_identifier(id)
      where(identifier: id).first
    end
  
    def self.current
      last
    end
  
    def sold_out?
      dates.each do |date|
        return false if !date.sold_out?
      end
      true
    end
  end
end
