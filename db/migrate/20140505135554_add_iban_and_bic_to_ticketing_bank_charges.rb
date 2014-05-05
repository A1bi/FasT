class AddIbanAndBicToTicketingBankCharges < ActiveRecord::Migration
  def change
    rename_column :ticketing_bank_charges, :number, :iban
    rename_column :ticketing_bank_charges, :blz, :bic
    remove_column :ticketing_bank_charges, :bank
    add_column :ticketing_bank_charges, :amount, :float
  end
  
  def migrate(direction)
    super
    change_table :ticketing_bank_charges do |t|
      if direction == :up
        t.change :iban, :string
        t.change :bic, :string
      else
        t.change :number, :integer
        t.change :blz, :integer
      end
    end
  end
end
