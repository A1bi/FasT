# frozen_string_literal: true

class ChangeTicketingOrdersPaid < ActiveRecord::Migration[6.0]
  def up
    change_column :ticketing_orders, :paid, :boolean, default: false, null: false
  end
end
