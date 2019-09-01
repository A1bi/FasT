module Api
  class ApiController < ApplicationController
    skip_authorization
    ignore_authenticity_token
  end
end
