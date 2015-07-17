class Api::BoxOfficeController < ApplicationController
  before_action :find_tickets, only: [:ticket_printable, :pick_up_tickets, :cancel_tickets]
  
  def place_order
    response = {
      ok: false,
      errors: []
    }
    
    info = params.require(:order)
    order = Ticketing::BoxOffice::Order.new
    order.box_office = Ticketing::BoxOffice::BoxOffice.first
    
    seating = NodeApi.seating_request("getChosenSeats", { clientId: info[:seatingId] }).body
    if !seating[:ok]
      response[:errors] << "Seating error"
      return render json: response
    end
    seats = seating[:seats]
    
		info[:tickets].each do |type_id, number|
			ticket_type = Ticketing::TicketType.find_by_id(type_id)
      next if !ticket_type || number < 1
      
      number.times do
        order.tickets.new({
          type: ticket_type,
          seat: Ticketing::Seat.find(seats.shift),
          date: Ticketing::EventDate.find(info[:date]),
          picked_up: true
        })
			end
		end
    
    ActiveRecord::Base.transaction do
      if order.save
        begin          
          NodeApi.update_seats_from_tickets(order.tickets)
    
          response[:ok] = true
          response[:order] = info_for_order(order)
          
        rescue
          response[:errors] << "Internal error"
          raise ActiveRecord::Rollback
        end
      else
        puts order.errors.messages
        response[:errors] << "Invalid order"
      end
    end
    
    render json: response
  end
  
  def cancel_order
    order = Ticketing::BoxOffice::Order.find_by_id(params[:id])
    if order
      tickets = order.tickets.to_a
      order.destroy
      NodeApi.update_seats_from_tickets(tickets)
    end
    render json: {}
  end
  
  def cancel_tickets
    order = @tickets.first.order
    
    # @tickets = order.tickets.cancelled(false).find(params[:ticket_ids])
    # workaround: autosave is not triggered when fetching the tickets like shown above
    @tickets = order.tickets.select do |ticket|
      params[:ticket_ids].include?(ticket.id.to_s) && !ticket.cancelled?
    end
    
    order.cancel_tickets(@tickets, :cancellation_at_box_office)
    if order.save
      NodeApi.update_seats_from_tickets(@tickets)
    end
    render json: { order: info_for_order(order) }
  end
  
  def purchase
    purchase = Ticketing::BoxOffice::Purchase.new
    purchase.pay_method = params[:pay_method]
    tickets = []
    
    params[:items].each do |item|
      purchase_item = purchase.items.new
      case item[:type]
      when "ticket"
        ticket = Ticketing::Ticket.find(item[:id].to_i)
        purchase_item.purchasable = ticket
        purchase_item.number = 1
        tickets << ticket
      when "product" 
        purchase_item.purchasable = Ticketing::BoxOffice::Product.find(item[:id].to_i)
        purchase_item.number = item[:number]
      when "refund"
        purchase_item.purchasable = Ticketing::BoxOffice::Refund.new
        purchase_item.purchasable.order = Ticketing::Order.find(item[:order])
        purchase_item.purchasable.amount = item[:amount]
        purchase_item.number = 1
      end
    end
    
    office = Ticketing::BoxOffice::BoxOffice.first
    office.purchases << purchase
    
    ok = false
    if office.save
      ok = true
      tickets.each do |ticket|
        ticket.picked_up = true
        ticket.save
      end
    end
    
    render json: { ok: ok }
  end
  
  def search
    orders = []
    if params[:q].present?
      if params[:q] =~ /\A(1|7)(\d{6})\z/
        if $1 == "1"
          orders << Ticketing::Order.where(number: $2).first
        else
          ticket = Ticketing::Ticket.where(number: $2).first
          orders << ticket.order if ticket
        end
        
      else
        table = Ticketing::Order.arel_table
        matches = nil
        (params[:q] + " " + ActiveSupport::Inflector.transliterate(params[:q])).split(" ").uniq.each do |term|
          match = table[:first_name].matches("%#{term}%").or(table[:last_name].matches("%#{term}%"))
          matches = matches ? matches.or(match) : match
        end
        orders = Ticketing::Order.where(matches).order(:last_name, :first_name)
      end
    end

    render json: {
      orders: orders.map { |o| info_for_order(o) }
    }
  end
  
  def ticket_printable
    pdf = TicketsRetailPDF.new
    pdf.add_tickets(@tickets)
    send_data pdf.render, type: "application/pdf", disposition: "inline"
  end
  
  def pick_up_tickets
    @tickets.update_all(picked_up: true)
    render json: {}
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
  
  def event
    event = Ticketing::Event.current
    
    response = {
      name: event.name,
      dates: event.dates.map { |date| { id: date.id.to_s, date: date.date.to_i } },
      ticket_types: Ticketing::TicketType.all.map { |type| { id: type.id.to_s, name: type.name, info: type.info || "", price: type.price || 0, exclusive: type.exclusive } },
      
      seats: Ticketing::Seat.all.map do |seat|
        { id: seat.id.to_s, block: { name: seat.block.name, color: seat.block.color }, row: seat.row.to_s, number: seat.number.to_s, grid: { x: seat.position_x, y: seat.position_y } }
      end
    }
    
    render :json => response
  end
  
  def products
    render json: {
      products: Ticketing::BoxOffice::Product.all.map do |product|
        {
          id: product.id,
          name: product.name,
          price: product.price
        }
      end
    }
  end
  
  private
  
  def find_tickets
    @tickets = Ticketing::Ticket.where(id: params[:ticket_ids])
  end
  
  def info_for_order(order)
    order.api_hash([:personal, :log_events, :tickets, :status, :billing], [:status])
  end
end