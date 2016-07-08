class AddPasswordToTicketingRetailStores < ActiveRecord::Migration
  def change
    add_column :ticketing_retail_stores, :password_digest, :string
  end
end
