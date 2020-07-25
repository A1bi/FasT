# frozen_string_literal: true

class AddActivationCodeToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :activation_code, :string
  end
end
