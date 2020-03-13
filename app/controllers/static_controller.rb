# frozen_string_literal: true

class StaticController < ApplicationController
  skip_authorization

  def index
    @alert_file = Rails.root.join('public/uploads/index_alert.json')
    @events = Ticketing::Event.where(identifier: %i[])
  end

  private

  def theater_play_path_exists?(event)
    template_exists?("theater/#{event.identifier}")
  end

  helper_method :theater_play_path_exists?
end
