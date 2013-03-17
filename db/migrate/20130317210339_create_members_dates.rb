class CreateMembersDates < ActiveRecord::Migration
  def change
    create_table :members_dates do |t|
      t.datetime :datetime
      t.string :info
      t.string :location

      t.timestamps
    end
  end
end
