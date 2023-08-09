# frozen_string_literal: true

class DropMembersDates < ActiveRecord::Migration[7.0]
  def change
    drop_table :members_dates do |t|
      t.datetime :datetime
      t.text :info
      t.string :location
      t.timestamps
      t.string :title
    end
  end
end
