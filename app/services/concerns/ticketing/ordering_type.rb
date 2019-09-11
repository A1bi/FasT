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
      return if type.blank? || web? || admin_action_authorized? ||
                retail_action_authorized?

      deny_access root_path
    end

    def admin_action_authorized?
      admin? && current_user&.admin?
    end

    def retail_action_authorized?
      retail? && retail_store_signed_in?
    end
  end
end
