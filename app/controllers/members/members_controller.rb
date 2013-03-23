class Members::MembersController < ApplicationController
	restrict_access_to_group :member
	
	before_filter :disable_slides
end
