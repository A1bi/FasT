# frozen_string_literal: true

class CreateTicketsBlocks < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets_blocks do |t|
      t.string :name

      t.timestamps
    end
  end
end
