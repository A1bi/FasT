# frozen_string_literal: true

module Ticketing
  class CheckInsChannel < ActionCable::Channel::Base
    def subscribed
      stream_for :all
    end
  end
end
