# frozen_string_literal: true

class AddPasswordToTicketingRetailStores < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_retail_stores, :password_digest, :string
  end
end
