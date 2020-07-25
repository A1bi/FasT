# frozen_string_literal: true

class ChangeRetailStoreAuth < ActiveRecord::Migration[6.0]
  def change
    remove_column :ticketing_retail_stores, :password_digest, :string

    add_belongs_to :users, :ticketing_retail_store, foreign_key: true

    change_column_null :users, :membership_fee, true
  end
end
