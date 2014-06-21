class RemoveBicFromTicketingBankCharges < ActiveRecord::Migration
  def up
    remove_column :ticketing_bank_charges, :bic
  end
  
  def down
    add_column :ticketing_bank_charges, :bic, :string
  end
end
