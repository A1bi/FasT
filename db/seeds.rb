# members
Member.create(email: "a.oster@online.de", password: "123456")

# gbook entries
[
	{ author: "Max Mustermann", text: "Hallo Welt!" },
	{ author: "Peter Schmidt", text: "Ich kollabier gleich..." }
].each do |entry|
	GbookEntry.create(entry)
end


## ticket system
# events
event = Tickets::Event.create(name: "Test-Event")
4.times do |i|
	# dates
	event.dates.create(date: Time.zone.now + i.days)
end

# seat blocks
3.times do |i|
	block = Tickets::Block.create(name: (i+1).to_s)
	
	# seats
	4.times do |row|
		10.times do |number|
			seat = block.seats.new
			seat.number = number+1
			seat.row = row+1
			seat.save
		end
	end
end

# ticket types
[
	{ name: "Kinder", price: 6.5 },
	{ name: "Erwachsene", price: 12.5 }
].each do |type|
	type = Tickets::TicketType.create(type)
end

# reservations
3.times do |i|
	r = Tickets::EventDate.order("RANDOM()").first.reservations.new
	r.seat = Tickets::Seat.order("RANDOM()").first
	r.save
end

# tickets
2.times do |i|
	ticket = Tickets::Ticket.new
	ticket.number = rand(100000..999999)
	ticket.type = Tickets::TicketType.order("RANDOM()").first
	Tickets::Reservation.order("RANDOM()").first.ticket = ticket
end