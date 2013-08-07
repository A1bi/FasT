class ChangeTicketingBankChargeNumber < ActiveRecord::Migration
  def up
    change_column :ticketing_bank_charges, :number, :integer, limit: 8
  end
end
