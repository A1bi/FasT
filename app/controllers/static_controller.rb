# frozen_string_literal: true

class StaticController < ApplicationController
  ALERT_FILE_PATH = Rails.public_path.join('uploads/index_alert.json')

  skip_authorization

  def index
    @featured_event = Ticketing::Event.find_by(identifier: :gatte_2023) # rubocop:disable Naming/VariableNumber
    @archived_events = Ticketing::Event.archived.ordered_by_dates(:desc)
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
