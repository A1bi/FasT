class Admin::BaseController < ApplicationController
  restrict_access_to_group :admin

  before_action :disable_slides
end
