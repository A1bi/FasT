# frozen_string_literal: true

class StaticController < ApplicationController
  ALERT_FILE_PATH = Rails.root.join('public/uploads/index_alert.json')

  skip_authorization

  def index
    @events = Ticketing::Event.where(identifier: %i[])
  end

  private

  def theater_play_path_exists?(event)
    template_exists?("theater/#{event.identifier}")
  end

  def show_alert?
    File.exist? ALERT_FILE_PATH
  end

  def alert_mtime
    File.mtime(ALERT_FILE_PATH).to_i
  end

  def alert_info
    JSON.parse(File.read(ALERT_FILE_PATH), symbolize_names: true)
  end

  helper_method :theater_play_path_exists?, :show_alert?, :alert_mtime,
                :alert_info
end
