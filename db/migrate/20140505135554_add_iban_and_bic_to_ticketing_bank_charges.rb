# frozen_string_literal: true

class AddIbanAndBicToTicketingBankCharges < ActiveRecord::Migration[6.0]
  def change
    change_table :ticketing_bank_charges, bulk: true do |t|
      t.rename :number, :iban
      t.rename :blz, :bic
      t.float :amount
    end
    remove_column :ticketing_bank_charges, :bank, :string
  end

  def migrate(direction)
    super
    change_table :ticketing_bank_charges do |t|
      if direction == :up
        t.change :iban, :string, limit: nil
        t.change :bic, :string
      else
        t.change :number, :integer, limit: 8
        t.change :blz, :integer
      end
    end
  end
end
