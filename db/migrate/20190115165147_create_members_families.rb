class CreateMembersFamilies < ActiveRecord::Migration[5.2]
  def change
    create_table :members_families, &:timestamps

    reversible do |dir|
      dir.up do
        add_belongs_to :members_members, :family

        Members::Member.where.not(related_to_id: nil).find_each do |member|
          related = Members::Member.find(member.related_to_id)
          member.add_to_family_with_member(related)
          member.save
        end

        remove_belongs_to :members_members, :related_to
      end

      dir.down do
        add_belongs_to :members_members, :related_to
        remove_belongs_to :members_members, :family
      end
    end
  end
end
