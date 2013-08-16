module Ticketing::BoxOffice
  class Product < ActiveRecord::Base
    attr_accessible :name, :price
  end
end