# frozen_string_literal: true

class AddMembersDestroyUserPermissions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    execute "ALTER TYPE permission ADD VALUE 'members_destroy' AFTER 'members_update'"
  end
end
