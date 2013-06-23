class CreateTicketingPassbookPasses < ActiveRecord::Migration
  def change
    create_table :passbook_passes do |t|
      t.string :type_id
      t.string :serial_number
      t.string :auth_token
      t.string :path
      
      t.timestamps
    end
    
    create_table :passbook_devices do |t|
      t.string :device_id
      t.string :push_token
      
      t.timestamps
    end
    
    create_table :passbook_registrations do |t|
      t.integer :pass_id
      t.integer :device_id
      
      t.timestamps
    end
    
    create_table :passbook_logs do |t|
      t.string :message
      
      t.timestamps
    end
  end
end
