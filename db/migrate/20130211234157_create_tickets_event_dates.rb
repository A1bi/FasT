class CreateTicketsEventDates < ActiveRecord::Migration
  def change
    create_table :tickets_event_dates do |t|
      t.datetime :date
      t.integer :event_id

      t.timestamps
    end
  end
end
