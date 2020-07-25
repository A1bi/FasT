# frozen_string_literal: true

class AddRelatedToToMembers < ActiveRecord::Migration[6.0]
  def change
    add_reference :members_members, :related_to
  end
end
