# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class Purchase < ApplicationRecord
      include Ticketing::Billable

      VAT_RATES = {
        standard: 19,
        reduced: 7,
        zero: 0
      }.freeze

      belongs_to :box_office
      belongs_to :tse_device, optional: true
      has_many :items, class_name: 'PurchaseItem', dependent: :destroy

      validates :items, length: { minimum: 1 }

      before_validation :update_total

      def total
        super || 0
      end

      def totals_by_vat_rate
        vat_items = items.group_by(&:vat_rate).symbolize_keys
        totals = VAT_RATES.each_with_object({}) do |(vat_id, rate), t|
          gross = vat_items.key?(vat_id) ? vat_items[vat_id].sum(&:total) : 0
          net = (gross / (1 + rate / 100.0)).round(2)
          vat = (gross - net).round(2)
          t[vat_id] = { net:, vat:, gross: }
        end

        totals[:total] = %i[net vat gross].index_with { |type| totals.values.pluck(type).sum.round(2) }

        totals
      end

      private

      def update_total
        # has to be called with &:total instead of :total because the total on the items might not be persisted yet
        self.total = items.sum(&:total)
      end
    end
  end
end
