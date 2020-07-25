# frozen_string_literal: true

class AddMembershipFeeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :membership_fee, :decimal

    reversible do |dir|
      dir.up do
        fee = Settings.members.default_membership_fee
        execute "UPDATE users SET membership_fee = #{fee.to_f}"
      end
    end

    change_column_null :users, :membership_fee, false
  end
end
