class Members::MembersController < ApplicationController
	restrict_access_to_group :member
end
