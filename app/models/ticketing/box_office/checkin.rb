module Ticketing::BoxOffice
  class Checkin < ActiveRecord::Base
    belongs_to :ticket, class_name: Ticketing::Ticket
    belongs_to :checkpoint
    
    validates_presence_of :ticket, :checkpoint
    
    default_scope { order(:created_at) }
  end
end