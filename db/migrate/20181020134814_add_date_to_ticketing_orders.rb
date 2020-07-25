# frozen_string_literal: true

class AddDateToTicketingOrders < ActiveRecord::Migration[6.0]
  def change
    add_reference :ticketing_orders, :date

    reversible do |dir|
      dir.up do
        Ticketing::Order.find_each(&:save)
      end
    end
  end
end
