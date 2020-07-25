# frozen_string_literal: true

class CreateTicketingBoxOfficePurchases < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_box_office_purchases do |t|
      t.integer :box_office_id
      t.float :total

      t.timestamps
    end

    create_table :ticketing_box_office_purchase_items do |t|
      t.integer :purchase_id
      t.integer :purchasable_id
      t.string :purchasable_type
      t.float :total
      t.integer :number

      t.timestamps
    end

    create_table :ticketing_box_office_products do |t|
      t.string :name
      t.float :price

      t.timestamps
    end

    create_table :ticketing_box_office_box_offices do |t|
      t.string :name

      t.timestamps
    end
  end
end
