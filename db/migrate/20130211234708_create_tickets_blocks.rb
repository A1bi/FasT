class CreateTicketsBlocks < ActiveRecord::Migration
  def change
    create_table :tickets_blocks do |t|
      t.string :name

      t.timestamps
    end
  end
end
