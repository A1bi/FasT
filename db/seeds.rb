# galleries
3.times do
  Gallery.create(
    title: FFaker::Lorem.sentence(4),
    disclaimer: "&copy; #{FFaker::NameDE.name}"
  )
end

# members
10.times do |i|
  attrs = if i.zero?
            {
              first_name: 'Albrecht',
              last_name: 'Oster',
              email: 'albrecht@oster.online',
              group: :admin
            }
          else
            {
              first_name: FFaker::NameDE.first_name,
              last_name: FFaker::NameDE.last_name,
              email: FFaker::Internet.free_email,
              group: :member
            }
          end
  attrs[:password] = '123456'
  attrs[:joined_at] = FFaker::Time.date
  member = Members::Member.new(attrs)
  member.save(valide: false)
end

# dates
locations = %i[hier da dort irgendwo nirgendwo]
titles = ['Dies', 'Das', 'Irgendwas', 'Tolle Sachen', 'Treffen XY']
5.times do
  date = 3.weeks.from_now + rand(200).hours
  Members::Date.create(
    datetime: date,
    info: FFaker::Lorem.sentence,
    title: titles.sample,
    location: locations.sample
  )
end

## newsletters
Newsletter::SubscriberList.create(name: 'Kunden')

3.times do
  Newsletter::Subscriber.create(email: FFaker::Internet.free_email)
end

## ticket system
seating = Ticketing::Seating.create(name: 'Dummy', number_of_seats: 20)

# events
event = Ticketing::Event.new(
  name: 'Testgloeckner',
  identifier: 'gloeckner',
  slug: 'der-test-gloeckner',
  location: 'Testbühne',
  sale_start: Time.zone.now - 1.week,
  seating: seating
)

4.times do |i|
  # dates
  event.dates.build(date: 4.weeks.from_now + i.days)
end

# ticket types
[
  { name: 'Ermäßigt', info: 'Kinder und so', price: 8.5 },
  { name: 'Erwachsene', price: 12.5 },
  { name: 'Freikarte', price: 0, availability: :exclusive }
].each do |type|
  event.ticket_types.build(type)
end

event.save

# retail stores
['Meyers Buchhandlung', 'Test-Store', 'Buchhandlung'].each do |name|
  Ticketing::Retail::Store.create(
    name: name,
    password: '123456',
    sale_enabled: true
  )
end

Ticketing::Retail::Store.last.users.create(
  email: 'store@example.com',
  password: '123456'
)

Ticketing::BoxOffice::BoxOffice.create(name: 'Testkasse')

# clear cache
Rails.cache.clear
