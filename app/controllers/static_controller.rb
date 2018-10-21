class StaticController < ApplicationController
  def index
    @alert_file = Rails.root.join('public', 'uploads', 'index_alert.json')
    @sahnemixx = Ticketing::Event.find_by(identifier: 'sahnemixx')
  end
end
