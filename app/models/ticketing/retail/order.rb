module Ticketing
  class Retail::Order < ActiveRecord::Base
    include Orderable

    belongs_to :store
  
    validates_presence_of :store
    
    before_create :set_queue_number
    
    def self.by_store(retailId)
      where(:store_id => retailId)
      .includes(:bunch).where("ticketing_bunches.paid != 1")
    end
    
    def set_queue_number
      return if queue_number
      
      number = 1
      until !self.class.exists?(queue_number: number, store_id: store) do
        number = number + 1
      end
      self[:queue_number] = number
    end
  end
end