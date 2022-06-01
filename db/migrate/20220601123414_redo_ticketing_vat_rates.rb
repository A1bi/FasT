# frozen_string_literal: true

class RedoTicketingVatRates < ActiveRecord::Migration[7.0]
  def change
    tables = %i[ticketing_box_office_products ticketing_ticket_types]

    create_enum :ticketing_vat_rate, %i[standard reduced zero]

    reversible do |dir|
      dir.up do
        tables.each do |table|
          add_column table, :vat_rate, :ticketing_vat_rate
          update "UPDATE #{table} SET vat_rate = 'zero'"
          change_column_null table, :vat_rate, false
        end
      end

      dir.down do
        tables.each do |table|
          remove_column table, :vat_rate

          insert <<-SQL.squish
            INSERT INTO ticketing_vat_rates
                        (rate, created_at, updated_at)
            VALUES      (0, NOW(), NOW())
          SQL

          update "UPDATE #{table} SET vat_rate_id = 1"

          change_column_null table, :vat_rate_id, false
        end
      end
    end

    tables.each do |table|
      remove_belongs_to table, :vat_rate, foreign_key: { to_table: :ticketing_vat_rates }
    end

    drop_table :ticketing_vat_rates do |t|
      t.decimal :rate, precision: 3, scale: 1, null: false
      t.timestamps
    end
  end
end
