def random(n)
	SecureRandom.random_number(n)
end

# gbook entries
11.times do
	GbookEntry.create(author: Faker::NameDE.name, text: Faker::Lorem.paragraph(5 + random(10)))
end

# galleries
3.times do
	Gallery.create(title: Faker::Lorem.sentence(4), disclaimer: "&copy; #{Faker::NameDE.name}")
end

# members
10.times do |i|
	attrs = { password: "123456" }
	if i == 1
		attrs.merge!({ first_name: "Albrecht", last_name: "Oster", email: "a.oster@online.de", group_name: :admin })
	else
		attrs.merge!({ first_name: Faker::NameDE.first_name, last_name: Faker::NameDE.last_name, email: Faker::Internet.free_email, group_name: :member })
	end
	member = Members::Member.new(attrs, without_protection: true)
	member.save(perform_validations: false)
end

# dates
locations = ["hier", "da", "dort", "irgendwo", "nirgendwo"]
5.times do
	date = Time.now + 3.weeks + random(4).days - random(1000).minutes
	Members::Date.create({ datetime: date, info: Faker::Lorem.sentence, location: locations.sample })
end

# files
Members::File.create({ title: "Test-Datei", description: Faker::Lorem.sentence(6), path: "dummy.pdf" })


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
	{ name: "Kinder", info: "Jugendliche bis 16 Jahre", price: 6.5 },
	{ name: "Erwachsene", price: 12.5 }
].each do |type|
	type = Tickets::TicketType.create(type, without_protection: true)
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


# clear cache
Rails.cache.clear
