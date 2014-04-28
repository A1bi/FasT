module Ticketing::BoxOffice
  class BoxOffice < ActiveRecord::Base
    has_many :purchases, dependent: :destroy
  end
end