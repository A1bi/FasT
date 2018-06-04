class StaticController < ApplicationController
  def index
    @event = Ticketing::Event.current
    @alert_file = Rails.root.join('public', 'uploads', 'index_alert.json')
  end
end
