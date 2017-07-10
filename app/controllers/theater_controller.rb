class TheaterController < ApplicationController
  before_action :disable_member_controls, :except => [:index]
  before_action :prepare_dates, only: [:jedermann, :don_camillo, :ladykillers, :alte_dame, :magdalena]

  private

  def prepare_dates
    @dates = (Ticketing::Event.by_identifier(params[:action]) || Ticketing::Event.first).dates.order(:date)
  end
end
