# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class Product < ApplicationRecord
      include HasVatRate

      validates :name, presence: true
      validates :price, numericality: { greater_than: 0 }
    end
  end
end
