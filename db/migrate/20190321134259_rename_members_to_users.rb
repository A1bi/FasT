class RenameMembersToUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table :members_members, :users

    add_column :users, :type, :string

    reversible do |dir|
      dir.up do
        execute('UPDATE users SET type = "Members::Member"')
      end
    end
  end
end
