# frozen_string_literal: true

class CreateTicketingBoxOfficeCheckins < ActiveRecord::Migration[6.0]
  def change
    create_table :ticketing_box_office_checkins do |t|
      t.integer :ticket_id
      t.integer :checkpoint_id
      t.boolean :in
      t.integer :medium

      t.timestamps
    end

    create_table :ticketing_box_office_checkpoints do |t|
      t.string :name

      t.timestamps
    end
  end
end
