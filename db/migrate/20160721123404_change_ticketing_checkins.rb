# frozen_string_literal: true

class ChangeTicketingCheckins < ActiveRecord::Migration[6.0]
  def change
    rename_table :ticketing_box_office_checkins, :ticketing_check_ins
    # rubocop:disable Rails/BulkChangeTable
    remove_column :ticketing_check_ins, :in, :boolean
    remove_timestamps :ticketing_check_ins
    add_column :ticketing_check_ins, :date, :datetime
    # rubocop:enable Rails/BulkChangeTable
  end
end
