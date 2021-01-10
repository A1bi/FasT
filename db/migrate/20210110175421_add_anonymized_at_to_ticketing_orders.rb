# frozen_string_literal: true

class AddAnonymizedAtToTicketingOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :ticketing_orders, :anonymized_at, :datetime
  end
end
