module Ticketing
  class Retail::Order < ActiveRecord::Base
    include Orderable

    belongs_to :store
  
    validates_presence_of :store
    
    attr_accessor :omit_queue_number
    before_create :set_queue_number, :if => Proc.new { |order| !order.omit_queue_number }
    after_save :push_to_checkout_clients
    after_destroy :push_to_checkout_clients
    
    def self.by_store(retailId)
      where(:store_id => retailId)
    end
    
    def set_queue_number
      return if queue_number
      
      number = 1
      until !self.class.exists?(queue_number: number, store_id: store) do
        number = number + 1
      end
      self[:queue_number] = number
    end
    
    private
    
    def push_to_checkout_clients
      NodeApi.push_to_retail_checkout("updateOrders", store.id, Retail::Order.by_store(store).api_hash)
    end
  end
end