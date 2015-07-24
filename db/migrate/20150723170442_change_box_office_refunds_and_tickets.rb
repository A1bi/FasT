class ChangeBoxOfficeRefundsAndTickets < ActiveRecord::Migration
  def change
    rename_table :ticketing_box_office_refunds, :ticketing_box_office_order_payments
    add_column :ticketing_tickets, :resale, :boolean, default: false
    add_column :ticketing_tickets, :invalidated, :boolean, default: false
    
    reversible do |change|
      change.up do
        update "UPDATE ticketing_box_office_purchase_items SET purchasable_type = 'Ticketing::BoxOffice::OrderPayment' WHERE purchasable_type = 'Ticketing::BoxOffice::Refund'"
        
        tickets = Arel::Table.new(:ticketing_tickets)
        update = Arel::UpdateManager.new(tickets.engine)
        update.table(tickets)
        update.set([[tickets[:invalidated], true]])
        update.where(tickets[:cancellation_id].not_eq(nil))
        ActiveRecord::Base.connection.execute(update.to_sql)
      end
      
      change.down do
        update "UPDATE ticketing_box_office_purchase_items SET purchasable_type = 'Ticketing::BoxOffice::Refund' WHERE purchasable_type = 'Ticketing::BoxOffice::OrderPayment'"
      end
    end
  end
end
