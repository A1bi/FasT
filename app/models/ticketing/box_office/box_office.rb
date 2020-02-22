# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class BoxOffice < ApplicationRecord
      include Ticketing::Billable

      has_many :purchases, dependent: :destroy, autosave: true
    end
  end
end
