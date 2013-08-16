module Ticketing::BoxOffice
  class Purchase < ActiveRecord::Base
    belongs_to :box_office
    has_many :items, class_name: PurchaseItem, after_add: :added_item, dependent: :destroy
    
    validates_presence_of :box_office
    validates_length_of :items, minimum: 1
    
    def total
      self[:total] || 0
    end
    
    private
    
    def added_item(item)
      self[:total] = item.total.to_f + total.to_f
    end
  end
end