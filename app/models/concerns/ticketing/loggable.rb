module Ticketing
  module Loggable
    extend ActiveSupport::Concern
    include ActionView::Helpers::TranslationHelper

    included do
      has_many :log_events, as: :loggable, dependent: :destroy, autosave: true
    end

    def log(event, info = nil)
      log_events.new({ name: event, info: info })
    end
  end
end
