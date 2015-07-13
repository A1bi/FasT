module Ticketing::BoxOffice
  class Purchase < BaseModel
    belongs_to :box_office
    has_many :items, class_name: PurchaseItem, dependent: :destroy
    
    validates_presence_of :box_office
    validates_length_of :items, minimum: 1
    
    before_validation :update_total
    
    def total
      self[:total] || 0
    end
    
    private
    
    def update_total
      self[:total] = 0
      items.each do |item|
        self[:total] = item.total.to_f + total.to_f
      end
    end
  end
end