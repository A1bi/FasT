# frozen_string_literal: true

class AddMembershipFeeDetailsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :membership_fee_paid_until, :date

    create_table :members_membership_fee_payments do |t|
      t.belongs_to :member, null: false
      t.decimal :amount, null: false
      t.date :paid_until, null: false
      t.belongs_to :debit_submission
      t.timestamps
    end

    create_table :members_membership_fee_debit_submissions, &:timestamps

    add_foreign_key :members_membership_fee_payments, :users, column: :member_id
    add_foreign_key :members_membership_fee_payments,
                    :members_membership_fee_debit_submissions,
                    column: :debit_submission_id
  end
end
