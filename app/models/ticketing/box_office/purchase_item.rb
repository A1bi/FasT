module Ticketing
  module BoxOffice
    class PurchaseItem < ApplicationRecord
      belongs_to :purchase
      belongs_to :purchasable, polymorphic: true, autosave: true

      def number
        self[:number] || 0
      end

      def purchasable=(record)
        super
        update_total
      end

      def number=(value)
        super
        update_total
      end

      private

      def update_total
        return if !number || !purchasable

        single = (purchasable.try(:price) || purchasable.total).to_f
        self[:total] = number * single
      end
    end
  end
end
