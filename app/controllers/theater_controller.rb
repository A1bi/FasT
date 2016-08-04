class TheaterController < ApplicationController
  before_filter :disable_member_controls, :except => [:index]
  before_filter :prepare_dates, only: [:jedermann, :don_camillo, :ladykillers, :alte_dame]

  private

  def prepare_dates
    @dates = (Ticketing::Event.by_identifier(params[:action]) || Ticketing::Event.first).dates.order(:date)
  end
end
