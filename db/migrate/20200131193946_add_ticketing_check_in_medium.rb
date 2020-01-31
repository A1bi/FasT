class AddTicketingCheckInMedium < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    execute "ALTER TYPE ticketing_check_in_medium ADD VALUE 'box_office_direct'"
  end
end
