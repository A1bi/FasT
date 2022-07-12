# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class FrontDisplayController < BaseController
      skip_authorization only: :index
      layout 'minimal'

      def index; end
    end
  end
end
