# frozen_string_literal: true

class DropTicketingCouponsReservationGroups < ActiveRecord::Migration[6.1]
  def change
    drop_table :ticketing_coupons_reservation_groups, id: false do |t|
      t.belongs_to :coupon, foreign_key: { to_table: :ticketing_coupons }
      t.belongs_to :reservation_group,
                   foreign_key: { to_table: :ticketing_reservation_groups },
                   index: { name: :index_ticketing_coupons_reservation_groups_on_group_id }
      t.timestamps null: false
    end
  end
end
