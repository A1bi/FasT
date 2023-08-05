# frozen_string_literal: true

class AddTicketingEventsUserPermissions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    %i[ticketing_events_read ticketing_events_update].each do |permission|
      execute "ALTER TYPE permission ADD VALUE '#{permission}'"
    end
  end
end
