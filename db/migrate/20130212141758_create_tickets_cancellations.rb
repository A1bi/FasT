# frozen_string_literal: true

class CreateTicketsCancellations < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets_cancellations do |t|
      t.string :reason

      t.timestamps
    end
  end
end
