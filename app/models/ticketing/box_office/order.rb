module Ticketing
  class BoxOffice::Order < Order
    belongs_to :box_office
    
    def cancel
      cancel_tickets(tickets, :box_office_instant_cancellation)
    end
  end
end