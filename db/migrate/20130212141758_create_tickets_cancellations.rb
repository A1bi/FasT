class CreateTicketsCancellations < ActiveRecord::Migration
  def change
    create_table :tickets_cancellations do |t|
      t.string :reason

      t.timestamps
    end
  end
end
