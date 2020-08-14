# frozen_string_literal: true

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
              group: :admin,
              permissions: %i[permissions_read permissions_update],
              shared_email_accounts_authorized_for:
                %w[info@theater-kaisersesch.de]
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
seating = Ticketing::Seating.create(name: 'Dummy', number_of_seats: 20)

## events
event_ids = %w[jedermann don_camillo ladykillers drachenjungfrau alte_dame
               alice_wunderland magdalena willibald sommernachtstraum herdmanns
               gemetzel gloeckner blauer_planet mit_abstand]

event_ids.each.with_index do |event_id, i|
  event = Ticketing::Event.new(
    name: "Testevent #{event_id.humanize.titleize}",
    identifier: event_id,
    slug: "test-event-#{event_id.dasherize}",
    location: 'Testbühne',
    seating: seating
  )

  # two most recent events will be the future
  if i > event_ids.count - 3
    event_date_base = (event_ids.count - i).months.from_now
  # older events will be in the past
  else
    event_date_base = (event_ids.count - i).years.ago
    event.archived = true
  end

  event.sale_start = event_date_base - 1.month

  unless event.archived
    4.times do |j|
      ### dates
      event.dates.build(date: event_date_base + j.weeks)
    end

    ### ticket types
    [
      { name: 'Ermäßigt', info: 'Kinder und so', price: 8.5 },
      { name: 'Erwachsene', price: 12.5 },
      { name: 'Freikarte', price: 0, availability: :exclusive }
    ].each do |type|
      event.ticket_types.build(type)
    end
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
  coupons << Ticketing::Coupon.create(recipient: FFaker::NameDE.name,
                                      free_tickets: 2)
end

## orders
def create_tickets(order, coupons = [])
  event = Ticketing::Event.with_future_dates.sample
  date = event.dates.sample
  ticket_types = event.ticket_types.to_a.shuffle

  rand(1..2).times do
    ticket_type = ticket_types.pop
    if ticket_type.price.zero?
      coupon = coupons.pop
      if coupon.present?
        coupon.update(free_tickets: 0)
        coupon.redeem
        order.coupons << coupon
      end
    end

    rand(1..3).times do
      ticket = order.tickets.new
      ticket.type = ticket_type
      ticket.date = date
    end
  end
end

### web orders
20.times do
  order = Ticketing::Web::Order.new(
    first_name: FFaker::NameDE.first_name,
    last_name: FFaker::NameDE.last_name,
    email: FFaker::Internet.free_email,
    phone: FFaker::PhoneNumberDE.phone_number,
    plz: FFaker::AddressDE.zip_code,
    affiliation: rand(3) == 2 ? FFaker::Company.name : nil,
    pay_method: Ticketing::Web::Order.pay_methods.keys.sample
  )

  if order.charge_payment?
    order.build_bank_charge(
      name: FFaker::NameDE.name,
      iban: 'DE89370400440532013000',
      approved: [true, false].sample
    )
  end

  create_tickets(order, coupons)

  order.save

  unless order.charge_payment? || [true, false].sample
    order.mark_as_paid
    order.save
  end
end

### retail orders
10.times do
  order = store.orders.new

  create_tickets(order)

  order.save
end

Ticketing::BoxOffice::BoxOffice.create(name: 'Testkasse')

# clear cache
Rails.cache.clear
