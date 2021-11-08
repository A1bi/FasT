# frozen_string_literal: true

class InfoController < ApplicationController
  skip_authorization

  def index
    if params[:event_slug].present?
      @event = Ticketing::Event.current.find_by!(slug: params[:event_slug])
      return head :not_found unless page_for_event_exists?

      render template_for_event
    else
      @event = Ticketing::Event.with_future_dates.last
      return redirect_to action: :freundeskreis unless page_for_event_exists?

      redirect_to event_slug: @event.slug
    end
  end

  def map
    @event = Ticketing::Event.current.find(params[:event_id])
  end

  private

  def page_for_event_exists?
    template_exists?("info/#{template_for_event}")
  end

  def template_for_event
    "index_#{@event.identifier}"
  end
end
