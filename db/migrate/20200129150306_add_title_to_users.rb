# frozen_string_literal: true

class AddTitleToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :title, :string
  end
end
