# frozen_string_literal: true

module Api
  class ApiController < ApplicationController
    skip_authorization
    ignore_authenticity_token

    private

    def user_not_authorized
      head :unauthorized
    end
  end
end
