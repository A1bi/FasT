# frozen_string_literal: true

module Ticketing
  class LogEvent < ApplicationRecord
    serialize :info

    belongs_to :user, optional: true
    belongs_to :loggable, polymorphic: true

    before_create :set_user

    def self.user=(user)
      RequestStore.store[:ticketing_log_events_user] = user
    end

    def info
      return {} if self[:info].is_a?(Array) || self[:info].nil?

      super
    end

    private

    def set_user
      self.user = RequestStore.store[:ticketing_log_events_user]
    end
  end
end
