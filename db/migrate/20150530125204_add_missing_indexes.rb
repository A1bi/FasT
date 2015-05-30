class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :passbook_devices, :device_id, unique: true
  end
end
