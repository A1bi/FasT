# frozen_string_literal: true

module Ticketing
  class LogEvent < ApplicationRecord
    serialize :info

    belongs_to :user, optional: true
    belongs_to :loggable, polymorphic: true

    def info
      return {} if self[:info].is_a?(Array) || self[:info].nil?

      super
    end
  end
end
