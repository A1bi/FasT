# frozen_string_literal: true

class AddInfoToTicketingEvents < ActiveRecord::Migration[7.0]
  def change
    change_table :ticketing_events, bulk: true do |t|
      t.boolean :ticketing_enabled, null: false, default: true, index: true
      t.jsonb :info, null: false, default: {}
    end

    reversible do |dir|
      dir.up do
        update <<~SQL.squish
          UPDATE ticketing_events
          SET info = info || format('{"subtitle": %s, "archived": %s}',
                                    COALESCE(CASE WHEN subtitle IS NULL THEN NULL ELSE '"' || subtitle || '"' END, 'null')
                                    , archived::text)::jsonb
        SQL
      end
    end

    change_table :ticketing_events, bulk: true do |t|
      t.remove :subtitle, type: :string
      t.remove :archived, type: :boolean, default: false
    end
  end
end
