class ChangeBoxOfficeRefundsAndTickets < ActiveRecord::Migration
  def change
    rename_table :ticketing_box_office_refunds, :ticketing_box_office_order_payments
    
    reversible do |change|
      change.up do
        update "UPDATE ticketing_box_office_purchase_items SET purchasable_type = 'Ticketing::BoxOffice::OrderPayment' WHERE purchasable_type = 'Ticketing::BoxOffice::Refund'"
      end
      
      change.down do
        update "UPDATE ticketing_box_office_purchase_items SET purchasable_type = 'Ticketing::BoxOffice::Refund' WHERE purchasable_type = 'Ticketing::BoxOffice::OrderPayment'"
      end
    end
  end
end
