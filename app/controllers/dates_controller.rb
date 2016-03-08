class DatesController < ApplicationController
  before_filter :prepare_ticket_prices
  before_filter :prepare_event
  
  def don_camillo
  end
  
  def jedermann
  end
  
  def alte_dame
    @structured_data = []

    @event.dates.each do |date|
      offers = []
      @ticket_types.each do |type|
        offers << {
          # url: "",
          name: type.name,
          category: "primary",
          price: type.price,
          priceCurrency: "EUR",
          validFrom: @event.sale_start.iso8601,
          availability: date.sold_out? ? "http://schema.org/SoldOut" : "http://schema.org/InStock"
        }
      end

      @structured_data << {
        "@context" => "http://schema.org",
        "@type" => "TheaterEvent",
        name: @event.name,
        # "image": "",
        # "url": "",
        startDate: date.date.iso8601,
        doorTime: date.door_time.iso8601,
        location: {
          "@type" => "PerformingArtsTheater",
          name: "Freilichtbühne am schiefen Turm",
          sameAs: root_url,
          address: "Burgstraße 2, 56759 Kaisersesch"
        },
        offers: offers,
        workPerformed: {
          "@type" => "CreativeWork",
          name: @event.name,
          sameAs: "https://de.wikipedia.org/wiki/Der_Besuch_der_alten_Dame"
        }
      }
    end
  end

  private
  
  def prepare_ticket_prices
    @ticket_types = Ticketing::TicketType.exclusive(false).order("price DESC")
  end
  
  def prepare_event
    @event = Ticketing::Event.by_identifier(params[:action]) || Ticketing::Event.first
  end
end
