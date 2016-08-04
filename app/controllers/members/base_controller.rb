class Members::BaseController < ApplicationController
  restrict_access_to_group :member

  before_filter :disable_slides
end
