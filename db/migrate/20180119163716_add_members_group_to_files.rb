class AddMembersGroupToFiles < ActiveRecord::Migration[5.1]
  def up
    change_column_default :members_members, :group, 0
    execute 'UPDATE `members_members` SET `group` = `group` - 1'
  end

  def down

    execute 'UPDATE `members_members` SET `group` = `group` + 1'
  end
end
