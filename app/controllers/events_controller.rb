# frozen_string_literal: true

class EventsController < ApplicationController
  include AnnouncementAlert

  skip_authorization

  before_action :find_event

  def show
    return head :not_found unless event_page_exists?(@event)

    @ticket_types = @event.ticket_types.except_exclusive
                          .ordered_by_availability_and_price
    @announcement = announcement_alert_text if show_announcement_alert?

    render @event.identifier
  end

  def map; end

  private

  def find_event
    @event = Ticketing::Event.including_ticketing_disabled.find_by!(slug: params[:slug])
  end

  def show_announcement_alert?
    super && !@event.past?
  end
end
