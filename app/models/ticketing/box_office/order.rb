# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class Order < Ticketing::Order
      belongs_to :box_office
    end
  end
end
