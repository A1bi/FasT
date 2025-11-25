# frozen_string_literal: true

json.array! @orders do |order|
  json.call(order, :id, :first_name, :last_name, :paid, :balance)
  json.number order.number.to_s

  json.tickets order.tickets do |ticket|
    json.call(ticket, :id)
    json.number ticket.number.to_s
    json.type ticket.type.name
    json.seat ticket.seat&.full_number
    json.checked_in ticket.check_ins.any?
  end
end
