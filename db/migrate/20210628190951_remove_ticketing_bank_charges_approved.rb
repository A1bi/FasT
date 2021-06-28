# frozen_string_literal: true

class RemoveTicketingBankChargesApproved < ActiveRecord::Migration[6.1]
  def change
    remove_column :ticketing_bank_charges, :approved, :boolean, default: false

    reversible do |dir|
      dir.up { execute 'DELETE FROM ticketing_log_events WHERE action = 3' }
    end
  end
end
