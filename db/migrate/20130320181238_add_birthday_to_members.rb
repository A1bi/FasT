# frozen_string_literal: true

class AddBirthdayToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :birthday, :date
  end
end
