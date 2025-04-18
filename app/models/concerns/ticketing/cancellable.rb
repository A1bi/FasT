# frozen_string_literal: true

module Ticketing
  module Cancellable
    extend ActiveSupport::Concern

    included do
      belongs_to :cancellation, optional: true
    end

    def cancelled?
      cancellation.present?
    end

    module ClassMethods
      def cancelled
        where.not(cancellation: nil)
      end

      def uncancelled
        where(cancellation: nil)
      end
    end
  end
end
