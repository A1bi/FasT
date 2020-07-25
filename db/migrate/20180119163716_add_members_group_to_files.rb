# frozen_string_literal: true

class AddMembersGroupToFiles < ActiveRecord::Migration[6.0]
  def up
    rename_table :members_files, :documents
    add_column :documents, :members_group, :integer, default: 0

    if File.exist?(old_path) && !File.exist?(new_path)
      FileUtils.mv(old_path, new_path)
    end

    change_column_default :members_members, :group, 0
    execute 'UPDATE members_members SET "group" = "group" - 1'
  end

  def down
    rename_table :documents, :members_files
    remove_column :members_files, :members_group

    if File.exist?(new_path) && !File.exist?(old_path)
      FileUtils.mv(new_path, old_path)
    end

    execute 'UPDATE members_members SET "group" = "group" + 1'
  end

  private

  def old_path
    Rails.public_path.join('system', 'members', 'files')
  end

  def new_path
    Rails.public_path.join('system', 'documents')
  end
end
