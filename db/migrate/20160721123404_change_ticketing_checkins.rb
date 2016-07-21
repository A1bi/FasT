class ChangeTicketingCheckins < ActiveRecord::Migration
  def change
    rename_table :ticketing_box_office_checkins, :ticketing_check_ins
    remove_column :ticketing_check_ins, :in, :boolean
    remove_timestamps :ticketing_check_ins
    add_column :ticketing_check_ins, :date, :datetime
  end
end
