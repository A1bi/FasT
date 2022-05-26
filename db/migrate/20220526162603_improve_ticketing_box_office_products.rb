# frozen_string_literal: true

class ImproveTicketingBoxOfficeProducts < ActiveRecord::Migration[7.0]
  def change
    %i[name price].each do |column|
      change_column_null :ticketing_box_office_products, column, false
    end

    reversible do |dir|
      dir.up do
        change_column :ticketing_box_office_products, :price, :decimal, precision: 8, scale: 2
      end
    end
  end
end
