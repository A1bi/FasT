class AddBirthdayToMembers < ActiveRecord::Migration
  def change
    add_column :members, :birthday, :date
  end
end
