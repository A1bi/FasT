# frozen_string_literal: true

class ChangeTicketingLogEventsInfo < ActiveRecord::Migration[6.1]
  def change
    rename_column :ticketing_log_events, :info, :info_tmp
    add_column :ticketing_log_events, :info, :jsonb

    reversible do |dir|
      dir.up do
        result = exec_query('SELECT id, info_tmp FROM ticketing_log_events')
        result.each do |event|
          next if event['info_tmp'].blank?

          info = YAML.safe_load(event['info_tmp'], [Symbol])
          next if info.empty?

          execute <<-SQL.squish
            UPDATE ticketing_log_events
            SET info = #{connection.quote(info.to_json)}
            WHERE id = #{event['id']}
          SQL
        end
      end
    end

    remove_column :ticketing_log_events, :info_tmp, :string
  end
end
