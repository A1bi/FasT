# frozen_string_literal: true

class FixPassbookLogs < ActiveRecord::Migration[6.0]
  def up
    change_column :passbook_logs, :message, :text, limit: 500
  end
end
