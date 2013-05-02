module Ticketing
  module Orderable
  	extend ActiveSupport::Concern
	
  	included do
      has_one :bunch, :as => :assignable, :validate => true
    
      validates_presence_of :bunch
		
  		class_eval do

  		end
  	end
  end
end