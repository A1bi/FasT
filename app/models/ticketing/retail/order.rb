module Ticketing
  class Retail::Order < ActiveRecord::Base
    include Orderable

    belongs_to :store
  
    validates_presence_of :store
    
    before_create :set_queue_number
    
    def mark_as_paid
      return if bunch.paid
      
      bunch.paid = true
      self[:queue_number] = nil
      bunch.save
      save
    end
    
    def self.by_store(retailId)
      where(:store_id => retailId)
      .includes(:bunch).where("ticketing_bunches.paid IS NOT 'true' OR ticketing_retail_orders.created_at > ?", Time.zone.now - 1.day)
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