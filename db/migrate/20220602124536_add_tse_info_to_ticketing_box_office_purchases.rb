# frozen_string_literal: true

class AddTseInfoToTicketingBoxOfficePurchases < ActiveRecord::Migration[7.0]
  def change
    add_column :ticketing_box_office_purchases, :tse_info, :jsonb
  end
end
