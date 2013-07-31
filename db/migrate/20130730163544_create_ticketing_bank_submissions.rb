class CreateTicketingBankSubmissions < ActiveRecord::Migration
  def change
    add_column :ticketing_bank_charges, :submission_id, :integer
    
    create_table :ticketing_bank_submissions do |t|
      t.timestamps
    end
  end
end
