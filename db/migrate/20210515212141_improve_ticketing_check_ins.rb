# frozen_string_literal: true

class ImproveTicketingCheckIns < ActiveRecord::Migration[6.1]
  def change
    change_column_null :ticketing_check_ins, :date, false, '1970-01-01'
    change_column_null :ticketing_check_ins, :medium, false, 'unknown'

    add_column :ticketing_check_ins, :created_at, :datetime, precision: 6
    update 'UPDATE ticketing_check_ins SET created_at = date'
    change_column_null :ticketing_check_ins, :created_at, false
  end
end
