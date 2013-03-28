class TheaterController < ApplicationController
	before_filter :disable_member_controls, :except => [:index]
end
