# frozen_string_literal: true

class RemoveActivationCodeFromUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users, bulk: true do |t|
      t.remove :activation_code, type: :string
      t.change_null :password_digest, false
    end
  end
end
