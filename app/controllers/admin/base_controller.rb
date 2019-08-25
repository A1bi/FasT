class Admin::BaseController < ApplicationController
  restrict_access_to_group :admin
end
