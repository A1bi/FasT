module Ticketing::BoxOffice
  class PurchaseItem < BaseModel
    belongs_to :purchase
    belongs_to :purchasable, polymorphic: true, autosave: true
  
    validates_presence_of :purchasable
    
    def number
      self[:number] || 0
    end
    
    def purchasable=(p)
      super p
      update_total
    end
    
    def number=(n)
      super n
      update_total
    end
    
    private
    
    def update_total
      return if !number || !purchasable
      self[:total] = number * (purchasable.respond_to?(:price) ? purchasable.price : purchasable.total).to_f
    end
  end
end