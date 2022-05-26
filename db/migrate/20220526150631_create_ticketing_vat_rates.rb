# frozen_string_literal: true

class CreateTicketingVatRates < ActiveRecord::Migration[7.0]
  def change
    create_table :ticketing_vat_rates do |t|
      t.decimal :rate, precision: 3, scale: 1, null: false
      t.timestamps
    end

    insert <<-SQL.squish # rubocop:disable Rails/SkipsModelValidations
      INSERT INTO ticketing_vat_rates
                  (rate, created_at, updated_at)
      VALUES      (0, NOW(), NOW())
    SQL

    %i[ticketing_box_office_products ticketing_ticket_types].each do |table|
      add_belongs_to table, :vat_rate, foreign_key: { to_table: :ticketing_vat_rates }

      update "UPDATE #{table} SET vat_rate_id = 1"

      change_column_null table, :vat_rate_id, false
    end
  end
end
