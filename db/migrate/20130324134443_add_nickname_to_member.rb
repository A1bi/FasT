# frozen_string_literal: true

class AddNicknameToMember < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :nickname, :string
  end
end
