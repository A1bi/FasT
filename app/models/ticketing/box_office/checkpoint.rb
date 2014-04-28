module Ticketing::BoxOffice
  class Checkpoint < ActiveRecord::Base
    has_many :checkins
  end
end