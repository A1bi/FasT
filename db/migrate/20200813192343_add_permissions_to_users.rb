# frozen_string_literal: true

class AddPermissionsToUsers < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          CREATE TYPE permission
              AS ENUM ('permissions_read', 'permissions_update')
        SQL
      end

      dir.down do
        execute <<-SQL.squish
          DROP TYPE permission
        SQL
      end
    end

    add_column :users, :permissions, :permission, array: true
  end
end
