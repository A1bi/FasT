class Admin::AdminController < ApplicationController
	restrict_access_to_group :admin
end
