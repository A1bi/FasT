# frozen_string_literal: true

class AddGenderToUsers < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute "CREATE TYPE gender AS ENUM ('female', 'male', 'diverse')"
      end

      dir.down do
        execute 'DROP TYPE gender'
      end
    end

    add_column :users, :gender, :gender
  end
end
