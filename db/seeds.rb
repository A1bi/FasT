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

# clear cache
Rails.cache.clear
