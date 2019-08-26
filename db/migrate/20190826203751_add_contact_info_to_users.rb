class AddContactInfoToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :street, :string
    add_column :users, :plz, :integer
    add_column :users, :city, :string
    add_column :users, :phone, :string
    add_column :users, :joined_at, :date
  end
end
