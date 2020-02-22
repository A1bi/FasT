# frozen_string_literal: true

module Api
  module Ticketing
    module BoxOffice
      class ProductsController < BaseController
        def index
          @products = ::Ticketing::BoxOffice::Product.all
        end
      end
    end
  end
end
