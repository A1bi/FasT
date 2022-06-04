# frozen_string_literal: true

class CreateTicketingTseDevices < ActiveRecord::Migration[7.0]
  def change
    create_table :ticketing_tse_devices do |t|
      t.string :serial_number, null: false, index: { unique: true }
      t.text :public_key, null: false
      t.timestamps
    end

    add_belongs_to :ticketing_box_office_purchases, :tse_device, foreign_key: { to_table: :ticketing_tse_devices }
  end
end
