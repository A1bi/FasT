json.array! event.dates.map do |date|
  json.set! '@context', 'http://schema.org'
  json.set! '@type', local_assigns.fetch(:event_type, 'TheaterEvent')

  json.name event.name
  json.image local_assigns[:image] ? asset_url(image) : nil
  json.url @event_url
  json.startDate date.date.iso8601
  json.doorTime date.door_time.iso8601

  json.location do
    json.set! '@type', local_assigns.fetch(:location_type,
                                           'PerformingArtsTheater')
    json.name local_assigns.fetch(:location_name,
                                  'Freilichtbühne am schiefen Turm')
    json.sameAs root_url
    json.address local_assigns.fetch(:location_address,
                                     'Burgstraße, 56759 Kaisersesch')
  end

  json.offers ticket_types do |type|
    json.url new_ticketing_order_url(event.slug)
    json.name type.name
    json.category 'primary'
    json.price type.price
    json.priceCurrency 'EUR'
    json.validFrom event.sale_start.iso8601
    json.availability "http://schema.org/#{item_availability(date)}"
  end
end
