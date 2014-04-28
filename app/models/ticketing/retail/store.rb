class Ticketing::Retail::Store < ActiveRecord::Base
  has_many :orders
end
