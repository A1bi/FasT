# frozen_string_literal: true

module Ticketing
  module OrderingType
    extend ActiveSupport::Concern

    TYPES = %i[web admin retail box_office].freeze

    def type
      params[:type]&.to_sym
    end

    TYPES.each do |t|
      define_method("#{t}?") { type == t }
    end
  end
end
