class AddRelatedToToMembers < ActiveRecord::Migration[5.2]
  def change
    add_reference :members_members, :related_to
  end
end
