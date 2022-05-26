# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class Product < ApplicationRecord
      belongs_to :vat_rate

      validates :name, presence: true
      validates :price, numericality: { greater_than: 0 }
    end
  end
end
