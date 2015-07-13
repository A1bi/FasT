module Ticketing::BoxOffice
  class BoxOffice < BaseModel
    include Ticketing::Billable
    
    has_many :purchases, dependent: :destroy, after_add: :added_purchase, autosave: true
    
    private
    
    def added_purchase(purchase)
      deposit_into_account(purchase.total, :cash_at_box_office)
      
      ticket_totals = {}
      purchase.items.each do |item|
        ticket = item.purchasable
        if ticket.is_a? Ticketing::Ticket
          ticket_totals[ticket.order] = (ticket_totals[ticket.order] || 0) + ticket.price
        end
      end
      
      ticket_totals.each do |order, total|
        transfer_to_account(order, total, :cash_at_box_office)
      end
    end
  end
end