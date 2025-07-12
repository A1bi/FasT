# frozen_string_literal: true

json.id order.id.to_s
json.number order.number.to_s
json.event_id order.event.id.to_s
json.created_at order.created_at.to_i

json.call(order, :total, :paid)

json.first_name order.try(:first_name)
json.last_name order.try(:last_name)

json.balance order.billing_account.balance

json.tickets order.tickets do |ticket|
  json.id ticket.id.to_s
  json.number ticket.number.to_s
  json.date_id ticket.date.id.to_s
  json.type_id ticket.type_id.to_s
  json.seat_id ticket.seat&.id.to_s
  json.cancelled ticket.cancelled?
  json.cancel_reason ticket.cancellation&.reason
  json.call(ticket, :price, :picked_up, :resale)
end

json.log_events order.log_events.reverse_order do |event|
  json.created_at event.created_at.to_i
  json.message translate_log_event(event)
end
