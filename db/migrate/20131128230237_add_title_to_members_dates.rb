class AddTitleToMembersDates < ActiveRecord::Migration
  def change
    add_column :members_dates, :title, :string
  end
end
