class AddCancellationToTicketingEventDates < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :ticketing_event_dates, :cancellation
  end
end
