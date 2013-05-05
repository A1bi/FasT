module Ticketing
  class Retail::Order < ActiveRecord::Base
    include Orderable

    belongs_to :store
  
    validates_presence_of :store
    
    def self.by_store(retailId)
      where(:store_id => retailId)
      .includes(:bunch).where("ticketing_bunches.paid IS NOT 'true' OR ticketing_retail_orders.created_at > ?", Time.zone.now - 1.day)
    end
  end
end