class CreateMembersFiles < ActiveRecord::Migration
  def change
    create_table :members_files do |t|
      t.string :title
      t.string :description
      t.string :path

      t.timestamps
    end
  end
end
