class StaticController < ApplicationController
  def index
    @alert_file = Rails.root.join('public', 'uploads', 'index_alert.json')
  end
end
