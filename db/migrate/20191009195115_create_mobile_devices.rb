class CreateMobileDevices < ActiveRecord::Migration[6.0]
  def change
    create_table :mobile_devices do |t|
      t.string :identifier
      t.uuid :udid, null: false
      t.string :product
      t.string :version
      t.timestamps
    end
  end
end
