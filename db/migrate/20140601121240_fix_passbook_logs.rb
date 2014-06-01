class FixPassbookLogs < ActiveRecord::Migration
  def up
   change_column :passbook_logs, :message, :text, limit: 500
  end
end
