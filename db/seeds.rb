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

3.times do
  Members::MembershipApplication.create(
    first_name: FFaker::NameDE.first_name,
    last_name: FFaker::NameDE.last_name,
    gender: :male,
    email: FFaker::Internet.free_email,
    birthday: FFaker::Time.date(year_range: 50, year_latest: 10),
    phone: FFaker::PhoneNumberDE.phone_number,
    street: FFaker::AddressDE.street_address,
    plz: FFaker::AddressDE.zip_code,
    city: FFaker::AddressDE.city,
    debtor_name: FFaker::NameDE.name,
    iban: 'DE89370400440532013000'
  )
end

member = Members::Member.new_from_membership_application(Members::MembershipApplication.last)
member.save

# newsletters
Newsletter::SubscriberList.create(name: 'Kunden')

3.times do
  Newsletter::Subscriber.create(email: FFaker::Internet.free_email)
end

# ticket system
ticketing_seeds = YAML.load_file(Rails.root.join('db/seeds/ticketing.yml'), symbolize_names: true)

## locations
location = Ticketing::Location.create(ticketing_seeds[:location])

## seating
seating = Ticketing::SeatingSvg::Importer.new(
  path: Rails.root.join('db/seeds/seating.svg')
).import(name: 'Dummy')

## events
events = ticketing_seeds[:events]
events.each.with_index do |event_info, i|
  # three most recent events will be in the future
  if i > events.count - 4
    event_date_base = (events.count - i).months.from_now
  # older events will be in the past
  else
    event_date_base = (events.count - i).years.ago
    past = true
  end
  event_date_base = event_date_base.change(hour: rand(17..20), minute: 0)

  with_seating = i >= events.count - 1

  event = Ticketing::Event.create(
    **event_info.slice(:identifier, :assets_identifier, :ticketing_enabled),
    name: "Test #{event_info[:name]}",
    slug: event_info.fetch(:slug, event_info[:name].parameterize),
    location:,
    # the most recent event will have the seating with a plan
    seating: with_seating ? seating : nil,
    number_of_seats: with_seating ? nil : 20,
    admission_duration: rand(30..60),
    sale_start: event_date_base - 2.months,
    info: {
      archived: true,
      subtitle: FFaker::Lorem.sentence,
      ensemble: ['Sommernachtstheater', 'Kammerensemble', 'Kinder- und Jugendtheater'].sample,
      **event_info.fetch(:info, {})
    }
  )

  (past ? 1 : 3).times do |j|
    event.dates.create(date: event_date_base + j.weeks)
  end

  next unless event.ticketing_enabled?

  ### ticket types
  ticketing_seeds[:ticket_types][..(past ? 0 : -1)].each do |type|
    event.ticket_types.create(
      **type,
      vat_rate: :reduced
    )
  end
end

## retail stores
store = Ticketing::Retail::Store.create(ticketing_seeds[:retail_store])
store.users.create(ticketing_seeds[:retail_store_user])

## coupons
coupons = []
10.times do
  coupon = Ticketing::Coupon.create(recipient: FFaker::NameDE.name, value_type: :free_tickets)
  coupon.deposit_into_account(3, :created_coupon)
  coupons << coupon
end

## orders
def create_tickets(order, coupons = [])
  event = Ticketing::Event.ticketing_enabled.with_future_dates.sample
  date = event.dates.sample
  ticket_types = event.ticket_types.to_a.shuffle
  seats = event.seating.seats.to_a if event.seating?

  rand(1..2).times do
    ticket_type = ticket_types.pop

    (num_tickets = rand(1..3)).times do
      ticket = order.tickets.new
      ticket.type = ticket_type
      ticket.date = date
      ticket.seat = seats.delete(seats.sample) if event.seating?
    end

    next unless ticket_type.price.zero?

    if (coupon = coupons.pop).present?
      coupon.withdraw_from_account(num_tickets, :redeemed_coupon)
      order.redeemed_coupons << coupon
    end
  end

  order.update_total
  order.withdraw_from_account(order.total, :order_created)
end

ticketing_seeds[:geolocations].each do |geolocation|
  Ticketing::Geolocation.create(
    postcode: geolocation[:postcode],
    cities: [geolocation[:city]],
    coordinates: geolocation[:coordinates]
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

  create_tickets(order, coupons)

  if order.charge_payment?
    order.bank_transactions.new(
      name: FFaker::NameDE.name,
      iban: 'DE89370400440532013000',
      amount: -order.balance
    )
    order.deposit_into_account(-order.balance, :bank_charge_payment)
  end

  order.update_paid
  order.save

  Ticketing::OrderPaymentService.new(order).mark_as_paid unless order.charge_payment? || [true, false].sample
end

### retail orders
10.times do
  order = store.orders.new

  create_tickets(order)

  order.transfer_to_account(store, order.balance, :cash_in_store)
  order.update_paid
  order.save
end

Ticketing::BoxOffice::BoxOffice.create(ticketing_seeds[:box_office])

# avoid processing emails for the created entities
Sidekiq::Queue.all.find { |queue| queue.name == 'mailers' }&.clear

# clear cache
Rails.cache.clear
