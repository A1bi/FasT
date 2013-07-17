module Ticketing
  module Loggable
  	extend ActiveSupport::Concern
	
  	included do
  		has_many :log_events, :as => :loggable, :dependent => :destroy
		
			def log(event, info = [])
				log_events.create({ name: event, info: info, member: @_member }, without_protection: true)
			end
  	end
  end
end