module Ticketing
  module BoxOffice
    class Purchase < ApplicationRecord
      include Ticketing::Billable

      belongs_to :box_office
      has_many :items, class_name: 'PurchaseItem', dependent: :destroy

      validates :items, length: { minimum: 1 }

      before_validation :update_total

      def total
        super || 0
      end

      private

      def update_total
        # has to be called with &:total instead of :total because the total
        # on the items might not be persisted yet
        self.total = items.sum(&:total)
      end
    end
  end
end
