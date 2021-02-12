# frozen_string_literal: true

module Ticketing
  class LogEvent < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :loggable, polymorphic: true

    def info
      super&.symbolize_keys || {}
    end
  end
end
