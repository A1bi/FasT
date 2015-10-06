class AddEventLocation < ActiveRecord::Migration
  def change
    add_column :ticketing_events, :location, :string
  end
end
