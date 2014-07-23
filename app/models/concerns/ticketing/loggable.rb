module Ticketing
  module Loggable
    extend ActiveSupport::Concern
    include ActionView::Helpers::TranslationHelper
  
    included do
      has_many :log_events, as: :loggable, dependent: :destroy
    end
    
    def log(event, info = nil)
      log_events.create({ name: event, info: info }) if persisted?
    end
    
    def api_hash(details = [])
      hash = defined?(super) ? super : {}
      hash.merge!({
        log_events: log_events.order(id: :desc).map do |event|
          {
            date: event.created_at.to_i,
            message: t(event.name, { scope: [:ticketing, :orders, :log_events] }.merge(event.info))
          }
        end
      }) if details.include? :log_events
      hash
    end
  end
end