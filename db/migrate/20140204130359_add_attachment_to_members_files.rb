class AddAttachmentToMembersFiles < ActiveRecord::Migration
  def change
    remove_column :members_files, :path
    add_attachment :members_files, :file
  end
end
