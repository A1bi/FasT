# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class Checkpoint < ApplicationRecord
      has_many :checkins, dependent: :nullify
    end
  end
end
