module Ticketing
  module OrderingType
    extend ActiveSupport::Concern

    TYPES = %i[web admin retail box_office].freeze

    included do
      if self < ActionController::Base && respond_to?(:helper_method)
        helper_method(TYPES.map { |t| "#{t}?" })
      end
    end

    def type
      params[:type]&.to_sym
    end

    TYPES.each do |t|
      define_method("#{t}?") { type == t }
    end
  end
end
