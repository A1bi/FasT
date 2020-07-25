# frozen_string_literal: true

class AddNumberToMembersMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :number, :integer
    add_index :users, :number, unique: true

    reversible do |dir|
      dir.up do
        Members::Member.order(:joined_at).each.with_index do |member, i|
          member.update(number: i + 1)
        end
      end
    end
  end
end
