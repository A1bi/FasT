module Ticketing
  module RandomUniqueID
  	extend ActiveSupport::Concern
	
  	module ClassMethods
      def has_random_unique_id(attr, digits)
        before_create do |record|
          min = 10 ** (digits - 1)
          max = 10 ** digits - min
          begin
            record[attr] = min + SecureRandom.random_number(max)
          end while self.class.exists?(attr => record[attr])
        end
      end
    end
  end
end