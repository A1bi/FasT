# frozen_string_literal: true

module Ticketing
  module Loggable
    extend ActiveSupport::Concern
    include ActionView::Helpers::TranslationHelper

    included do
      has_many :log_events,
               as: :loggable, inverse_of: :loggable, dependent: :destroy
    end

    def log(event, info = nil)
      log_events.new(name: event, info: info)
    end

    def log!(event, info = nil)
      log(event, info).save
    end
  end
end
