module Ticketing
  module Cancellable
  	extend ActiveSupport::Concern
  	include Loggable
	
  	included do
  		belongs_to :cancellation
		
  		class_eval do
  			def cancel(reason)
  				self.create_cancellation({ reason: reason }, without_protection: true)
  				self.save
  				self.log(:cancelled)
  			end
	
  			def cancelled?
  				self.cancellation.present?
  			end
  		end
  	end
  end
end