class DatesController < ApplicationController
  include ActionView::Helpers::AssetUrlHelper

  skip_authorization

  def index
    event = Ticketing::Event.with_future_dates.last
    redirect_to dates_event_path(event.slug)
  end

  def teaser; end

  def show_event
    @event = Ticketing::Event.current.find_by!(slug: params[:slug])
    @ticket_types = @event.ticket_types.exclusive(false).order(price: :desc)
    render "event_#{@event.identifier}"
  end

  private

  def structured_data(event, image: nil, creative_work_url: nil)
    # TODO: add availability state for 'not on sale anymore'
    event.dates.map do |date|
      {
        '@context' => 'http://schema.org',
        '@type' => 'TheaterEvent',
        name: event.name,
        image: image ? asset_url(image) : nil,
        url: @event_url,
        startDate: date.date.iso8601,
        doorTime: date.door_time.iso8601,
        location: {
          '@type' => 'PerformingArtsTheater',
          name: 'Freilichtbühne am schiefen Turm',
          sameAs: root_url,
          address: event.location
        },
        offers: event.ticket_types.exclusive(false).map do |type|
          {
            url: new_ticketing_order_url(event.slug),
            name: type.name,
            category: 'primary',
            price: type.price,
            priceCurrency: 'EUR',
            validFrom: event.sale_start.iso8601,
            availability: date.sold_out? ? 'http://schema.org/SoldOut' : 'http://schema.org/InStock'
          }
        end,
        workPerformed: if @creative_work_url
                         {
                           '@type' => 'CreativeWork',
                           name: event.name,
                           sameAs: creative_work_url
                         }
                       end
      }
    end
  end
  helper_method :structured_data
end
