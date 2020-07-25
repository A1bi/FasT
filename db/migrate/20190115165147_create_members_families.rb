# frozen_string_literal: true

class CreateMembersFamilies < ActiveRecord::Migration[6.0]
  def change
    create_table :members_families, &:timestamps

    reversible do |dir|
      dir.up do
        add_belongs_to :members_members, :family

        # set table name to be able to migrate from an older schema
        Members::Member.table_name = 'members_members'

        Members::Member.where.not(related_to_id: nil).find_each do |member|
          related = Members::Member.find(member.related_to_id)
          member.add_to_family_with_member(related)
          member.save
        end

        # restore table name for later migrations
        Members::Member.table_name = 'users'

        remove_belongs_to :members_members, :related_to
      end

      dir.down do
        add_belongs_to :members_members, :related_to
        remove_belongs_to :members_members, :family
      end
    end
  end
end
