# frozen_string_literal: true

class AddInternetAccessSessionsUserPermissions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    execute <<~SQL.squish
      ALTER TYPE permission ADD VALUE 'internet_access_sessions_create';
      COMMIT;
      UPDATE users SET permissions = array_append(permissions, 'internet_access_sessions_create')
    SQL
  end
end
