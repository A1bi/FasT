# frozen_string_literal: true

class AddMissingIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :passbook_devices, :device_id, unique: true
  end
end
