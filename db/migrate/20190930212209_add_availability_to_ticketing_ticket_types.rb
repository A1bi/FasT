# frozen_string_literal: true

class AddAvailabilityToTicketingTicketTypes < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:ticketing_ticket_types, :exclusive,
                          from: false, to: nil)

    rename_column :ticketing_ticket_types, :exclusive, :availability

    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          CREATE TYPE ticketing_ticket_type_availability
            AS ENUM ('universal', 'exclusive', 'box_office');

          ALTER TABLE ticketing_ticket_types
            ALTER COLUMN availability TYPE ticketing_ticket_type_availability
            USING CASE availability
              WHEN TRUE THEN 'exclusive'::ticketing_ticket_type_availability
              WHEN FALSE THEN 'universal'::ticketing_ticket_type_availability
            END;
        SQL
      end

      dir.down do
        execute <<-SQL.squish
          ALTER TABLE ticketing_ticket_types
            ALTER COLUMN availability TYPE BOOLEAN
            USING CASE availability
              WHEN 'exclusive'::ticketing_ticket_type_availability THEN TRUE
              WHEN 'universal'::ticketing_ticket_type_availability THEN FALSE
            END;

          DROP TYPE ticketing_ticket_type_availability;
        SQL
      end
    end
  end
end
