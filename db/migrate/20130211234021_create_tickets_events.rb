class CreateTicketsEvents < ActiveRecord::Migration
  def change
    create_table :tickets_events do |t|
      t.string :name

      t.timestamps
    end
  end
end
