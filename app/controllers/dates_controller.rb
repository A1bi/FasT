class DatesController < ApplicationController
  skip_authorization

  def index
    event = Ticketing::Event.with_future_dates.last
    redirect_to dates_event_path(event.slug)
  end

  def show_event
    @event = Ticketing::Event.current.find_by!(slug: params[:slug])
    @ticket_types = @event.ticket_types.except_exclusive
                          .ordered_by_availability_and_price
    render "event_#{@event.identifier}"
  end
end
