# frozen_string_literal: true

class StaticController < ApplicationController
  include AnnouncementAlert

  before_action :authorize

  helper :photos, :events

  def index
    @upcoming_events = Ticketing::Event.with_future_dates.ordered_by_dates
    @upcoming_dates = Ticketing::EventDate.upcoming.order(date: :asc)
    @archived_events = Ticketing::Event.including_ticketing_disabled.archived.ordered_by_dates(:desc)
                                       .includes(:location)
  end

  private

  def authorize
    super(:static)
  end
end
