class DatesController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper

  before_action :prepare_ticket_types
  before_action :prepare_event

  def sommernachtstraum
    @creative_work_url = "https://de.wikipedia.org/wiki/Ein_Sommernachtstraum"
  end

  private

  def prepare_ticket_types
    @ticket_types = Ticketing::TicketType.exclusive(false).order(price: :desc)
    puts Ticketing::TicketType.exclusive(false).count
  end

  def prepare_event
    @event = Ticketing::Event.by_identifier(params[:action]) || Ticketing::Event.first
  end

  def structured_data
    data = []

    @event.dates.each do |date|
      offers = []
      @ticket_types.each do |type|
        offers << {
          url: new_ticketing_order_url,
          name: type.name,
          category: "primary",
          price: type.price,
          priceCurrency: "EUR",
          validFrom: @event.sale_start.iso8601,
          availability: date.sold_out? ? "http://schema.org/SoldOut" : "http://schema.org/InStock"
        }
      end

      event = {
        "@context" => "http://schema.org",
        "@type" => "TheaterEvent",
        name: @event.name,
        image: @event_image ? asset_url(@event_image) : nil,
        url: @event_url,
        startDate: date.date.iso8601,
        doorTime: date.door_time.iso8601,
        location: {
          "@type" => "PerformingArtsTheater",
          name: "Freilichtbühne am schiefen Turm",
          sameAs: root_url,
          address: "Burgstraße 2, 56759 Kaisersesch"
        },
        offers: offers
      }

      if @creative_work_url
        event[:workPerformed] = {
          "@type" => "CreativeWork",
          name: @event.name,
          sameAs: @creative_work_url
        }
      end

      data << event
    end

    data
  end
  helper_method :structured_data
end
