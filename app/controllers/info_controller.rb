class InfoController < ApplicationController
  skip_authorization

  def index
    if params[:event_slug].present?
      @event = Ticketing::Event.current.find_by!(slug: params[:event_slug])
    else
      @event = Ticketing::Event.with_future_dates.first
      return redirect_to event_slug: @event.slug
    end

    template = "index_#{@event.identifier}"
    if template_exists?("info/#{template}")
      render template
    else
      redirect_to action: :index
    end
  end

  def map
    return if params[:identifier].blank?
    template = "map_#{params[:identifier]}"
    render template if template_exists?("info/#{template}")
  end
end
