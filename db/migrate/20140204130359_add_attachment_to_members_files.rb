# frozen_string_literal: true

class AddAttachmentToMembersFiles < ActiveRecord::Migration[6.0]
  def change
    remove_column :members_files, :path, :string
    add_attachment :members_files, :file
  end
end
