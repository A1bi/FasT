class InfoController < ApplicationController
  skip_authorization

  def index
    if params[:event_slug].present?
      @event = Ticketing::Event.current.find_by!(slug: params[:event_slug])
    else
      @event = Ticketing::Event.with_future_dates.last || Ticketing::Event.last
      return redirect_to event_slug: @event.slug
    end

    template = "index_#{@event.identifier}"
    return head :not_found unless template_exists?("info/#{template}")

    render template
  end

  def map
    return if params[:identifier].blank?

    template = "map_#{params[:identifier]}"
    render template if template_exists?("info/#{template}")
  end
end
