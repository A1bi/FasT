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


## members
10.times do |i|
	attrs = { password: "123456" }
	if i == 1
		attrs.merge!({ first_name: "Albrecht", last_name: "Oster", email: "a.oster@online.de", group_name: :admin })
	else
		attrs.merge!({ first_name: Faker::NameDE.first_name, last_name: Faker::NameDE.last_name, email: Faker::Internet.free_email, group_name: :member })
	end
	member = Members::Member.new(attrs)
	member.save(perform_validations: false)
end

# dates
locations = ["hier", "da", "dort", "irgendwo", "nirgendwo"]
titles = ["Dies", "Das", "Irgendwas", "Tolle Sachen", "Treffen XY"]
5.times do
	date = Time.now + 3.weeks + random(4).days - random(1000).minutes
	Members::Date.create({ datetime: date, info: Faker::Lorem.sentence, title: titles.sample, location: locations.sample })
end

# files
# Members::File.create({ title: "Test-Datei", description: Faker::Lorem.sentence(6), path: "dummy.pdf" })


## newsletters
3.times do
  Newsletter::Subscriber.create(email: Faker::Internet.free_email)
end


## ticket system
# events
event = Ticketing::Event.create({ name: "Test Jedermann", identifier: "jedermann" })
4.times do |i|
	# dates
	event.dates.create(date: Time.zone.now + i.days)
end

# seat blocks
block_names = %w(rot grün blau)
colors = %w(red green blue)
x = 5
y = 5
3.times do |i|
	block = Ticketing::Block.create(name: block_names[i], color: colors[i])
	
	# seats
	x2 = nil
	6.times do |row|
		x2 = x
		y2 = y + row * 5
		6.times do |number|
			seat = block.seats.new
			seat.number = number+1
			seat.row = row+1
			seat.position_x = x2
			seat.position_y = y2
			seat.save
			x2 = x2 + 4
		end
	end
	
	x = x2 + 6
end

# ticket types
[
	{ name: "Kinder", info: "Jugendliche bis 16 Jahre", price: 6.5 },
	{ name: "Erwachsene", price: 12.5 }
].each do |type|
	type = Ticketing::TicketType.create(type)
end

# retail stores
["Meyers Buchhandlung", "Test-Store", "Buchhandlung"].each do |name|
  Ticketing::Retail::Store.create(name: name, password: SecureRandom.hex)
end

# retail orders
# available_seats = Ticketing::Seat.includes(:tickets, :reservations).having("COUNT(ticketing_tickets.id) + COUNT(ticketing_reservations.id) < 1").group("ticketing_seats.id")
# date = Ticketing::EventDate.last
# i = 0
# 3.times do
#   order = Ticketing::Retail::Order.new
#   order.store = Ticketing::Retail::Store.first
#   order.build_bunch
#   
#   (1 + random(5)).times do
#     ticket = Ticketing::Ticket.new
#     ticket.date = date
#     ticket.seat = available_seats.offset(i).first
#     ticket.type = Ticketing::TicketType.order("RANDOM()").first
#     order.bunch.tickets << ticket
#     i = i+1
#   end
#   
#   order.save
# end

# clear cache
Rails.cache.clear
