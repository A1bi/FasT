module Api
  module Ticketing
    module BoxOffice
      class PurchasesController < BaseController
        def create
          purchase = ::Ticketing::BoxOffice::PurchaseCreateService.new(
            params, current_box_office
          ).execute

          head purchase.persisted? ? :ok : :bad_request
        end
      end
    end
  end
end
