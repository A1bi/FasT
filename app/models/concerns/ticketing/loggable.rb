module Ticketing
  module Loggable
    extend ActiveSupport::Concern
    include ActionView::Helpers::TranslationHelper

    included do
      has_many :log_events, -> { order(created_at: :desc) },
               as: :loggable, inverse_of: :loggable, dependent: :destroy,
               autosave: true
    end

    def log(event, info = nil)
      log_events.new({ name: event, info: info })
    end
  end
end
