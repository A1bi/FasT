# frozen_string_literal: true

class RenameMembers < ActiveRecord::Migration[6.0]
  def change
    rename_table :members, :members_members
  end
end
