module Ticketing::BoxOffice
  class Checkpoint < ActiveRecord::Base
    attr_accessible :name
    
    has_many :checkins
  end
end