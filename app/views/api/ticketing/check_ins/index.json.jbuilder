# frozen_string_literal: true

json.signing_keys @signing_keys, :id, :secret

json.dates @dates, :id, :date

json.seats @seats, :id, :block_id

json.blocks @blocks, :id, :entrance

json.ticket_types @ticket_types, :id, :name

json.changed_tickets @changed_tickets do |ticket|
  json.call(ticket, :id, :date_id, :number, :type_id, :seat_id)
  json.cancelled ticket.cancelled?
  json.seat_number @covid19_seats[ticket.order.number] if ticket.event.covid19?
end
