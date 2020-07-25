# frozen_string_literal: true

class CreateTicketingBankSubmissions < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_bank_charges, :submission_id, :integer

    create_table :ticketing_bank_submissions, &:timestamps
  end
end
