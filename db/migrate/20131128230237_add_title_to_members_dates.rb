class AddTitleToMembersDates < ActiveRecord::Migration
  def change
    add_column :members_dates, :title, :string
  end
  
  def migrate(direction)
    super

    Members::Date.update_all(title: "Probe") if direction == :up
  end
end
