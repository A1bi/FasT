# frozen_string_literal: true

class CreateMembershipApplications < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up { change_column :users, :plz, :string }
      dir.down { change_column :users, :plz, :integer, using: 'plz::integer' }
    end

    create_table :members_membership_applications do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :title
      t.column :gender, :gender, null: false
      t.string :email, null: false
      t.string :street, null: false
      t.string :plz, null: false
      t.string :city, null: false
      t.datetime :birthday, null: false
      t.string :phone
      t.string :debtor_name, null: false
      t.string :iban, null: false
      t.timestamps
    end
  end
end
