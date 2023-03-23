# frozen_string_literal: true

class StaticController < ApplicationController
  ALERT_FILE_PATH = Rails.public_path.join('uploads/index_alert.json')

  skip_authorization

  def index
    @events = Ticketing::Event.with_future_dates.ordered_by_dates
  end

  private

  def show_alert?
    File.exist? ALERT_FILE_PATH
  end

  def alert_mtime
    File.mtime(ALERT_FILE_PATH).to_i
  end

  def alert_info
    JSON.parse(File.read(ALERT_FILE_PATH), symbolize_names: true)
  end

  helper_method :show_alert?, :alert_mtime, :alert_info
end
