class CreateTicketsLogEvents < ActiveRecord::Migration
  def change
    create_table :tickets_log_events do |t|
      t.string :name
      t.string :info
			t.integer :member_id
			t.string :loggable_type
			t.integer :loggable_id

      t.timestamps
    end
  end
end
