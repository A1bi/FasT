# frozen_string_literal: true

class FixTicketsBunchCancellationId < ActiveRecord::Migration[6.0]
  def change
    rename_column :tickets_bunches, :cencellation_id, :cancellation_id
  end
end
