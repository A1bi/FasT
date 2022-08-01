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
        merge(uncancelled.invert_where)
      end

      def uncancelled
        where.missing(:cancellation)
      end
    end
  end
end
