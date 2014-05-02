module Ticketing
  class Retail::Order < Order
    belongs_to :store
  
    validates_presence_of :store
    
    def self.by_store(retail_id)
      where(:store_id => retail_id)
    end
  end
end