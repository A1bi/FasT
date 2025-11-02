# frozen_string_literal: true

ticket = order.tickets.first
event = ticket.event
order_url = order_url(order)

json.set! '@context', schema_context
json.set! '@type', 'EventReservation'
json.reservationStatus reservation_status(ticket)

json.reservationFor do
  json.set! '@type', 'Event'
  json.name event.name
  json.startDate ticket.date.date.iso8601
  json.doorTime ticket.date.admission_time.iso8601

  json.location do
    json.set! '@type', 'Place'
    json.name event.location.name
    json.address do
      json.set! '@type', 'PostalAddress'
      json.streetAddress event.location.street
      json.postalCode event.location.postcode
      json.addressLocality event.location.city
      json.addressRegion 'Rheinland-Pfalz'
      json.addressCountry 'DE'
    end
  end
end

# Apple specific
json.reservationId order.number
json.url order_url

json.reservedTicket do
  json.set! '@type', 'Ticket'
  json.ticketNumber ticket.number
  if ticket.seat.present?
    json.ticketedSeat do
      json.seatSection ticket.seat.block.name
      json.seatRow ticket.seat.row if ticket.seat.row
      json.seatNumber ticket.seat.number
    end
  end
end

# Google specific
json.cancelReservationUrl order_url
json.modifyReservationUrl order_url
json.reservationNumber order.number
json.ticketNumber ticket.number
if ticket.seat.present?
  json.venueSection ticket.seat.block.name
  json.venueRow ticket.seat.row if ticket.seat.row
  json.venueSeat ticket.seat.number
end

json.underName do
  json.set! '@type', 'Person'
  json.name "#{order.first_name} #{order.last_name}" if order.is_a? Ticketing::Web::Order
end
