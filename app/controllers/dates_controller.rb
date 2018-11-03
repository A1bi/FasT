class DatesController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper

  def teaser
    @herdmanns = Ticketing::Event.find_by(identifier: 'herdmanns')
  end

  def event
    @event = Ticketing::Event.find_by!(identifier: params[:slug])
    @ticket_types = @event.ticket_types.exclusive(false).order(price: :desc)
  end

  private

  def structured_data
    data = []

    # TODO: add availability state for 'not on sale anymore'

    @event.dates.each do |date|
      offers = []
      @ticket_types.each do |type|
        offers << {
          url: new_ticketing_order_url(@event.slug),
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
