# frozen_string_literal: true

class CreateMembersFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :members_files do |t|
      t.string :title
      t.string :description
      t.string :path

      t.timestamps
    end
  end
end
