module Ticketing
  module OrderingType
    extend ActiveSupport::Concern

    TYPES = %i[web admin retail box_office].freeze

    included do
      next unless self < ActionController::Base

      helper_method(TYPES.map { |t| "#{t}?" }) if respond_to?(:helper_method)

      prepend_before_action :authorize_type
    end

    class_methods do
      protected

      def skip_authorization
        super

        skip_before_action :authorize_type
      end
    end

    def type
      params[:type]&.to_sym
    end

    TYPES.each do |t|
      define_method("#{t}?") { type == t }
    end

    private

    def authorize_type
      return if web? || admin? && current_user&.admin? ||
                retail? && retail_store_signed_in?

      deny_access root_path
    end
  end
end
