class AddPasswordToTicketingRetailStores < ActiveRecord::Migration
  def change
    add_column :ticketing_retail_stores, :password_digest, :string
  end
  
  def migrate(direction)
    super
    if direction == :up
      Ticketing::Retail::Store.all.each do |store|
        store.password = SecureRandom.hex
        store.save
      end
    end
  end
end
