module Ticketing::BoxOffice
  class BoxOffice < ActiveRecord::Base
    attr_accessible :name
  
    has_many :purchases, dependent: :destroy
  end
end