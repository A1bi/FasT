# frozen_string_literal: true

json.array! event.dates.map do |date|
  json.set! '@context', schema_context
  json.set! '@type', local_assigns.fetch(:event_type, 'TheaterEvent')

  json.name event.name
  json.image local_assigns[:image] ? asset_url(image) : nil
  json.startDate date.date.iso8601
  json.doorTime date.admission_time.iso8601
  json.eventStatus event_status(date)

  json.location do
    json.set! '@type', local_assigns.fetch(:location_type, 'EventVenue')
    json.name event.location.name
    json.address do
      json.streetAddress event.location.street
      json.postalCode event.location.postcode
      json.addressLocality event.location.city
      json.addressCountry 'DE'
    end
    json.latitude event.location.coordinates.x
    json.longitude event.location.coordinates.y
    json.sameAs root_url
  end

  json.offers event.ticket_types.except_exclusive do |type|
    json.url new_ticketing_order_url(event.slug)
    json.name type.name
    json.category 'primary'
    json.price type.price
    json.priceCurrency 'EUR'
    json.validFrom event.sale_start.iso8601
    json.availability item_availability(date)
  end
end
