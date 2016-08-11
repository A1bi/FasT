class Members::BaseController < ApplicationController
  restrict_access_to_group :member

  before_action :disable_slides
end
