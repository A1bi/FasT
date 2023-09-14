# frozen_string_literal: true

class StaticController < ApplicationController
  ALERT_FILE_PATH = Rails.public_path.join('uploads/index_alert.json')

  skip_authorization

  helper :photos, :events

  def index
    @featured_events = Ticketing::Event.where(identifier: %i[arschlings canterville])
    @featured_galleries = Rails.env.development? ? [Gallery.last] * @featured_events.count : Gallery.where(id: [76, 77])
    @upcoming_dates = Ticketing::EventDate.upcoming.order(date: :asc)
    @archived_events = Ticketing::Event.including_ticketing_disabled.archived.ordered_by_dates(:desc)
                                       .includes(:location)
    flash.now[:warning] = alert_info[:text].html_safe if show_alert? # rubocop:disable Rails/OutputSafety
  end

  private

  def show_alert?
    File.exist? ALERT_FILE_PATH
  end

  def alert_info
    JSON.parse(File.read(ALERT_FILE_PATH), symbolize_names: true)
  end
end
