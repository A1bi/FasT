module Ticketing
  module Loggable
    extend ActiveSupport::Concern
  
    included do
      has_many :log_events, as: :loggable, dependent: :destroy
    end
    
    def log(event, info = nil)
      log_events.create({ name: event, info: info })
    end
  end
end