# frozen_string_literal: true

module Ticketing
  class VatRate < ApplicationRecord
    validates :rate, numericality: { greater_than: 0 }
  end
end
