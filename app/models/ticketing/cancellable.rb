module Ticketing
  module Cancellable
  	extend ActiveSupport::Concern
	
  	included do
  		belongs_to :cancellation
		
			def cancel(reason)
        return if cancelled?
				create_cancellation({ reason: reason }, without_protection: true)
				save
				log(:cancelled) if respond_to? :loggable
			end

			def cancelled?
				cancellation.present?
			end
  	end
  end
end