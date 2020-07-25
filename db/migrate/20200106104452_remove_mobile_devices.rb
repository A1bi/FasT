# frozen_string_literal: true

class RemoveMobileDevices < ActiveRecord::Migration[6.0]
  def change
    drop_table :mobile_devices do |t|
      t.string :identifier
      t.uuid :udid, null: false
      t.string :product
      t.string :version
      t.timestamps
    end
  end
end
