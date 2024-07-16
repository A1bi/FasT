# frozen_string_literal: true

class ImproveTicketingCheckIns < ActiveRecord::Migration[6.1]
  def change
    change_table :ticketing_check_ins, bulk: true do |t|
      t.change_null :date, false, '1970-01-01'
      t.change_null :medium, false, 'unknown'
    end

    add_column :ticketing_check_ins, :created_at, :datetime, precision: 6
    update 'UPDATE ticketing_check_ins SET created_at = date'
    change_column_null :ticketing_check_ins, :created_at, false
  end
end
