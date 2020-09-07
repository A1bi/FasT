# frozen_string_literal: true

class AddMoreUserPermissions < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    execute <<~SQL.squish
      ALTER TYPE permission ADD VALUE 'members_read';
      ALTER TYPE permission ADD VALUE 'members_update';
      ALTER TYPE permission ADD VALUE 'newsletters_read';
      ALTER TYPE permission ADD VALUE 'newsletters_update';
      ALTER TYPE permission ADD VALUE 'newsletters_approve';
    SQL
  end
end
