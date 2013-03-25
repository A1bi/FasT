class Admin::BaseController < ApplicationController
	restrict_access_to_group :admin
	
	before_filter :disable_slides
end
