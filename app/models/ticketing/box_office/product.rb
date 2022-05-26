# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class Product < ApplicationRecord
      belongs_to :vat_rate
    end
  end
end
