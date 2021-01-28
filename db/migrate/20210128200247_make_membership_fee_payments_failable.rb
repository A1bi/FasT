# frozen_string_literal: true

class MakeMembershipFeePaymentsFailable < ActiveRecord::Migration[6.1]
  def change
    add_column :members_membership_fee_payments, :failed, :boolean,
               null: false, default: false
    add_column :users, :membership_fee_payments_paused, :boolean,
               null: false, default: false
  end
end
