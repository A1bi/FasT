# frozen_string_literal: true

class ChangeTicketingWebOrderPlzToString < ActiveRecord::Migration[6.0]
  def up
    change_column :ticketing_web_orders, :plz, :string
  end

  def down
    change_column :ticketing_web_orders, :plz, :integer
  end
end
