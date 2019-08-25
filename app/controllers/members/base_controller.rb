class Members::BaseController < ApplicationController
  restrict_access_to_group :member
end
