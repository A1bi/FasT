json.events @events do |event|
  json.id event.id.to_s
  json.call(event, :name)

  json.dates event.dates do |date|
    json.id date.id.to_s
    json.date date.date.to_i
  end

  json.ticket_types event.ticket_types do |type|
    json.id type.id.to_s
    json.name type.name
    json.info type.info || ''
    json.price type.price || 0
    json.exclusive type.exclusive
  end

  json.bound_to_seats event.seating.bound_to_seats?

  json.seats event.seating.seats do |seat|
    json.id seat.id.to_s
    json.block_name seat.block.name
    json.row seat.row.to_s
    json.number seat.number.to_s
  end
end
