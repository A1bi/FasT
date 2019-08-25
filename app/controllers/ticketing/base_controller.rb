module Ticketing
  class BaseController < ApplicationController
    include RetailStoreAuthenticatable
    include OrderingType

    restrict_access_to_group :admin

    before_action :disable_slides
    before_action :disable_member_controls_for_retail

    helper TicketingHelper

    private

    def orders_path(action, params = nil)
      action = action.to_s.sub('ticketing', 'ticketing_retail') if retail?
      send("#{action}_path", params)
    end
    helper_method :orders_path

    def disable_member_controls_for_retail
      disable_member_controls if retail? && !user_signed_in?
    end
  end
end
