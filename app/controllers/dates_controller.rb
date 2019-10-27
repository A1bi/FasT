class DatesController < ApplicationController
  skip_authorization

  def index
    event = available_events.last || Ticketing::Event.last
    redirect_to dates_event_path(event.slug)
  end

  def show_event
    @event = available_events.find_by!(slug: params[:slug])
    @ticket_types = @event.ticket_types.except_exclusive
                          .ordered_by_availability_and_price
    render "event_#{@event.identifier}"
  end

  private

  def available_events
    Ticketing::Event.with_future_dates
  end
end
