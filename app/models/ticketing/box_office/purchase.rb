module Ticketing::BoxOffice
  class Purchase < BaseModel
    include Ticketing::Billable
    
    belongs_to :box_office
    has_many :items, class_name: PurchaseItem, dependent: :destroy
    
    validates_presence_of :box_office
    validates_length_of :items, minimum: 1
    
    before_validation :update_total
    before_create :bill
    
    def total
      self[:total] || 0
    end
    
    private
    
    def bill      
      case pay_method
      when "cash"
        transfer_to_account(box_office, -total, :cash_at_box_office)
      when "electronic_cash" 
        deposit_into_account(total, :electronic_cash_at_box_office)
      end
      
      product_total = 0
      ticket_totals = {}
      items.each do |item|
        purchasable = item.purchasable
        case purchasable
        when Product
          product_total = product_total + item.total
        when OrderPayment
          note = purchasable.amount < 0 ? :cash_refund_at_box_office : :cash_at_box_office
          transfer_to_account(purchasable.order, purchasable.amount, note)
        when Ticketing::Ticket
          ticket_totals[purchasable.order] = (ticket_totals[purchasable.order] || 0) + purchasable.price
        end
      end
      
      withdraw_from_account(product_total, :purchased_products)
      
      ticket_totals.each do |order, total|
        note_key = :cash_at_box_office
        if pay_method == "electronic_cash" 
          note_key = :electronic_cash_at_box_office
        end
        transfer_to_account(order, total, :cash_at_box_office)
      end
    end
    
    def update_total
      self[:total] = 0
      items.each do |item|
        self[:total] = item.total.to_f + total.to_f
      end
    end
  end
end