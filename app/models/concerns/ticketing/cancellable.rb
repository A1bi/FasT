module Ticketing
  module Cancellable
  	extend ActiveSupport::Concern
	
  	included do
  		belongs_to :cancellation
    end
		
    def cancel(reason)
      return if cancelled?
      if reason.is_a? Ticketing::Cancellation
        self.cancellation = reason
      else
        create_cancellation({ reason: reason })
      end
      save
    end

    def cancelled?
      cancellation.present?
    end
    
    def api_hash
      {
        cancelled: cancelled?,
        cancel_reason: cancelled? ? cancellation.reason : nil
      }
    end
    
    module ClassMethods
      def cancelled(cancelled = true)
        where(arel_table[:cancellation_id].send((cancelled ? :not_eq : :eq), nil))
      end
    end
  end
end