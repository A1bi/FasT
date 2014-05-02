class Api::PurchasesController < ApplicationController
  def create
    purchase = Ticketing::BoxOffice::Purchase.new
    purchase.box_office = Ticketing::BoxOffice::BoxOffice.find(params[:box_office])

    (params[:items] ||= []).each do |itemInfo|
      item = Ticketing::BoxOffice::PurchaseItem.new
      item.purchasable = (itemInfo[:type] == "order" ? Ticketing::Order : Ticketing::BoxOffice::Product).find(itemInfo[:id])
      if itemInfo[:type] == "order"
        item.number = 1
        item.purchasable.paid = true
        item.purchasable.save
      else
        item.number = itemInfo[:number]
      end
      purchase.items << item
    end
    
    new_order = nil
    info = params[:new_order]
    if info
      order = Ticketing::Order.new
      order.paid = true
    
      seating = NodeApi.seating_request("getChosenSeats", { clientId: params[:seating_id] }).body
      if seating[:ok]
        seats = seating[:seats]

    		info[:tickets].each do |type_id, number|
          number = number.to_i
    			ticket_type = Ticketing::TicketType.find_by_id(type_id)
          next if !ticket_type || number < 1
  
          number.times do
    				ticket = Ticketing::Ticket.new
    				ticket.type = ticket_type
    				ticket.seat = Ticketing::Seat.find(seats.shift)
            ticket.date = Ticketing::EventDate.find(info[:date])
            order.tickets << ticket
    			end
    		end
      
        if order.save
          item = Ticketing::BoxOffice::PurchaseItem.new
          item.number = 1
          item.purchasable = order
          purchase.items << item
          
          seats = {}
          order.tickets.each do |ticket|
            seats.deep_merge! ticket.date_id => Hash[[ticket.seat.node_hash(ticket.date_id)]]
          end
          NodeApi.update_seats(seats)
        
          new_order = {
            id: order.id.to_s,
            number: order.number.to_s,
            tickets: order.tickets.map do |ticket|
              { id: ticket.id.to_s, number: ticket.number.to_s, dateId: ticket.date.id.to_s, typeId: ticket.type_id.to_s, price: ticket.price, seatId: ticket.seat.id.to_s }
            end
          }
        else
          return render json: { ok: false }
        end
      else
        return render json: { ok: false }
      end
    end
    
    response = { ok: purchase.save }
    response[:new_order] = new_order if new_order
    render json: response
  end
  
  def unlock_seats
    seats = {}
    Ticketing::ReservationGroup.all.each do |reservation_group|
      reservation_group.reservations.each do |reservation|
        (seats[reservation.date.id] ||= []) << reservation.seat.id
      end
    end
    NodeApi.seating_request("setExclusiveSeats", { clientId: params[:seating_id], seats: seats }) if seats.any?
    render nothing: true
  end
end