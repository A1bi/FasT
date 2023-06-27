# frozen_string_literal: true

# galleries
3.times do |i|
  Gallery.create(
    title: FFaker::Lorem.sentence(4),
    disclaimer: FFaker::NameDE.name,
    position: i
  )
end

# members
10.times do |i|
  attrs = if i.zero?
            {
              first_name: 'Albrecht',
              last_name: 'Oster',
              gender: :male,
              email: 'albrecht@oster.online',
              group: :admin,
              permissions: User::PERMISSIONS,
              shared_email_accounts_authorized_for:
                %w[info@theater-kaisersesch.de]
            }
          else
            {
              first_name: FFaker::NameDE.first_name,
              last_name: FFaker::NameDE.last_name,
              gender: Members::Member.genders.sample,
              email: FFaker::Internet.free_email,
              group: :member
            }
          end

  attrs[:password] = '123456'
  attrs[:birthday] = FFaker::Time.date(year_range: 50, year_latest: 10)
  attrs[:joined_at] = FFaker::Time.date
  attrs[:phone] = FFaker::PhoneNumberDE.phone_number
  attrs[:street] = FFaker::AddressDE.street_address
  attrs[:plz] = FFaker::AddressDE.zip_code
  attrs[:city] = FFaker::AddressDE.city

  member = Members::Member.new(attrs)

  member.build_sepa_mandate(
    debtor_name: member.name.full,
    iban: 'DE89370400440532013000'
  )

  member.save
  next unless rand(2) == 1

  member.renew_membership!
  next unless rand(5) == 1

  member.terminate_membership!
end

Members::MembershipFeeDebitSubmission.create(
  payments: Members::MembershipFeePayment.all
)

# dates
locations = %i[hier da dort irgendwo nirgendwo]
titles = ['Dies', 'Das', 'Irgendwas', 'Tolle Sachen', 'Treffen XY']
5.times do
  Members::Date.create(
    datetime: 3.weeks.from_now + rand(200).hours,
    info: FFaker::Lorem.sentence,
    title: titles.sample,
    location: locations.sample
  )
end

# newsletters
Newsletter::SubscriberList.create(name: 'Kunden')

3.times do
  Newsletter::Subscriber.create(email: FFaker::Internet.free_email)
end

# ticket system

## locations
location = Ticketing::Location.create(
  name: 'Testbühne',
  street: 'Teststraße 1',
  postcode: '12345',
  city: 'Testhausen',
  coordinates: [50.7992, 6.8828]
)

## seatings
seatings = []
seatings << Ticketing::Seating.create(name: 'Dummy', number_of_seats: 20)
seatings << Ticketing::SeatingSvg::Importer.new(
  path: Rails.root.join('db/seeds/seating.svg')
).import(name: 'Dummy')

## events
event_ids = %w[jedermann don_camillo ladykillers drachenjungfrau alte_dame
               alice_wunderland magdalena willibald sommernachtstraum herdmanns
               gloeckner blauer_planet mit_abstand frau_mueller abba gatte gemetzel arschlings]

event_ids.each.with_index do |event_id, i|
  event = Ticketing::Event.new(
    name: "Testevent #{event_id.humanize.titleize}",
    identifier: event_id,
    slug: "test-event-#{event_id.dasherize}",
    location:,
    # the most recent event will have the seating with a plan
    seating: seatings[i >= event_ids.count - 1 ? 1 : 0],
    admission_duration: rand(30..60)
  )

  event.covid19 = true if i == event_ids.count - 1

  # three most recent events will be the future
  if i > event_ids.count - 4
    event_date_base = (event_ids.count - i).months.from_now
  # older events will be in the past
  else
    event_date_base = (event_ids.count - i).years.ago
    event.archived = true
  end

  event.sale_start = event_date_base - 1.month

  4.times do |j|
    ### dates
    event.dates.build(date: event_date_base + j.weeks)
    break if event.archived?
  end

  ### ticket types
  [
    { name: 'Ermäßigt', info: 'Kinder und so', price: 8.5 },
    { name: 'Erwachsene', price: 12.5 },
    { name: 'Freikarte', price: 0, availability: :exclusive }
  ].each do |type|
    event.ticket_types.build(
      **type,
      vat_rate: :reduced
    )
    break if event.archived?
  end

  event.save
end

## retail stores
store = Ticketing::Retail::Store.create(
  name: 'Testbuchhandlung',
  sale_enabled: true
)

store.users.create(
  email: 'store@example.com',
  password: '123456'
)

## coupons
coupons = []
10.times do
  coupon = Ticketing::Coupon.create(recipient: FFaker::NameDE.name, value_type: :free_tickets)
  coupon.deposit_into_account(3, :created_coupon)
  coupons << coupon
end

## orders
def create_tickets(order, coupons = [])
  event = Ticketing::Event.with_future_dates.sample
  date = event.dates.sample
  ticket_types = event.ticket_types.to_a.shuffle

  rand(1..2).times do
    ticket_type = ticket_types.pop

    (num_tickets = rand(1..3)).times do
      ticket = order.tickets.new
      ticket.type = ticket_type
      ticket.date = date
      next unless event.seating.plan?

      loop do
        ticket.seat = event.seating.seats.sample
        break unless ticket.seat.taken?(date)
      end

      next unless event.covid19?
    end

    next unless ticket_type.price.zero?

    if (coupon = coupons.pop).present?
      coupon.withdraw_from_account(num_tickets, :redeemed_coupon)
      order.redeemed_coupons << coupon
    end
  end
end

5.times do
  Ticketing::Geolocation.create(
    postcode: FFaker::AddressDE.zip_code,
    cities: [FFaker::AddressDE.city],
    coordinates: [FFaker::Geolocation.lat, FFaker::Geolocation.lng]
  )
end
postcodes = Ticketing::Geolocation.pluck(:postcode)

### web orders
20.times do
  order = Ticketing::Web::Order.new(
    first_name: FFaker::NameDE.first_name,
    last_name: FFaker::NameDE.last_name,
    gender: rand(0..1),
    email: FFaker::Internet.free_email,
    phone: FFaker::PhoneNumberDE.phone_number,
    plz: postcodes.sample,
    affiliation: rand(3) == 2 ? FFaker::Company.name : nil,
    pay_method: Ticketing::Web::Order.pay_methods.keys.sample
  )

  if order.charge_payment?
    order.bank_transactions.new(
      name: FFaker::NameDE.name,
      iban: 'DE89370400440532013000',
      amount: 15
    )
  end

  create_tickets(order, coupons)

  order.save

  Ticketing::OrderPaymentService.new(order).mark_as_paid unless order.charge_payment? || [true, false].sample
end

### retail orders
10.times do
  order = store.orders.new

  create_tickets(order)

  order.save
end

Ticketing::BoxOffice::BoxOffice.create(name: 'Testkasse')

# avoid processing emails for the created entities
Sidekiq::Queue.all.find { |queue| queue.name == 'mailers' }&.clear

# clear cache
Rails.cache.clear
