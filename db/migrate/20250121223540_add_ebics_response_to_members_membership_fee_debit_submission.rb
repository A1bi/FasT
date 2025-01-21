# frozen_string_literal: true

class AddEbicsResponseToMembersMembershipFeeDebitSubmission < ActiveRecord::Migration[8.0]
  def change
    add_column :members_membership_fee_debit_submissions, :ebics_response, :jsonb
  end
end
