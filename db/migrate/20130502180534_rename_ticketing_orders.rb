# frozen_string_literal: true

class RenameTicketingOrders < ActiveRecord::Migration[6.0]
  def change
    rename_table :ticketing_orders, :ticketing_web_orders
  end
end
