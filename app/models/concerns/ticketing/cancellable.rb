# frozen_string_literal: true

module Ticketing
  module Cancellable
    extend ActiveSupport::Concern

    included do
      belongs_to :cancellation, optional: true, autosave: true
    end

    def cancel(reason)
      return if cancelled?

      if reason.is_a? Ticketing::Cancellation
        self.cancellation = reason
      else
        build_cancellation(reason: reason)
      end
      save
      cancellation
    end

    def cancelled?
      cancellation.present?
    end

    module ClassMethods
      def cancelled
        where.not(cancellation_id: nil)
      end
    end
  end
end
