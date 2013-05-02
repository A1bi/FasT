module Ticketing
  module Loggable
  	extend ActiveSupport::Concern
	
  	included do
  		has_many :log_events, :as => :loggable
		
  		class_eval do
  			def log(event, info = [])
  				self.log_events.create({ name: event, info: info, member: @_member }, without_protection: true)
  			end
  		end
  	end
  end
end