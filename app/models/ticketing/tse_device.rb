# frozen_string_literal: true

module Ticketing
  class TseDevice < ApplicationRecord
    validates :serial_number, :public_key, presence: true
  end
end
