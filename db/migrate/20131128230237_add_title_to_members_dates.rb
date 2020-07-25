# frozen_string_literal: true

class AddTitleToMembersDates < ActiveRecord::Migration[6.0]
  def change
    add_column :members_dates, :title, :string
  end
end
