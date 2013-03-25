class RenameMembers < ActiveRecord::Migration
  def change
		rename_table :members, :members_members
  end
end
