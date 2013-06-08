class FixTicketsBunchCancellationId < ActiveRecord::Migration
  def change
		rename_column :tickets_bunches, :cencellation_id, :cancellation_id
  end
end
