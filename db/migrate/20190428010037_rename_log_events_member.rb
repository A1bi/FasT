class RenameLogEventsMember < ActiveRecord::Migration[5.2]
  def change
    rename_column :ticketing_log_events, :member_id, :user_id
  end
end
