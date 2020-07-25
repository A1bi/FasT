# frozen_string_literal: true

class RenameLogEventsMember < ActiveRecord::Migration[6.0]
  def change
    rename_column :ticketing_log_events, :member_id, :user_id
  end
end
