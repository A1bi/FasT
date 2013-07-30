class AddApprovedToTicketingBankCharges < ActiveRecord::Migration
  def change
    add_column :ticketing_bank_charges, :approved, :boolean, default: false
  end
end
