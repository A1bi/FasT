module Ticketing
  module Cancellable
  	extend ActiveSupport::Concern
	
  	included do
  		belongs_to :cancellation
		
			def cancel(reason)
        return if cancelled?
				create_cancellation({ reason: reason })
				save
			end

			def cancelled?
				cancellation.present?
			end
  	end
    
    module ClassMethods
      def cancelled(cancelled = true)
        where(arel_table[:cancellation_id].send((cancelled ? :not_eq : :eq), nil))
      end
    end
  end
end