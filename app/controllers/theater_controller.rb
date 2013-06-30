class TheaterController < ApplicationController
	before_filter :disable_member_controls, :except => [:index]
  
  def jedermann
    @dates = Ticketing::Event.by_identifier("jedermann").dates.order(:date)
  end
    
end
