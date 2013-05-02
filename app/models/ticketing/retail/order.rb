module Ticketing
  class Retail::Order < ActiveRecord::Base
    include Orderable

    belongs_to :store
  
    validates_presence_of :store
  end
end