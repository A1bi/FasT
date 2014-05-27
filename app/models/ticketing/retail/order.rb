module Ticketing
  class Retail::Order < Order
    belongs_to :store
  
    validates_presence_of :store
    
    before_create :before_create
    
    def self.by_store(retail_id)
      where(:store_id => retail_id)
    end
    
    private
    
    def before_create
      self.paid = true
    end
  end
end