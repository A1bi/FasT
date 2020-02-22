# frozen_string_literal: true

module Ticketing
  class Block < ApplicationRecord
    belongs_to :seating
    has_many :seats, dependent: :destroy
  end
end
