# frozen_string_literal: true

class CreateMembersDates < ActiveRecord::Migration[6.0]
  def change
    create_table :members_dates do |t|
      t.datetime :datetime
      t.string :info
      t.string :location

      t.timestamps
    end
  end
end
