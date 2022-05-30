# frozen_string_literal: true

class AddTseInformationToTicketingBoxOffices < ActiveRecord::Migration[7.0]
  def change
    add_column :ticketing_box_office_box_offices, :tse_client_id, :string
    add_index :ticketing_box_office_box_offices, :tse_client_id, unique: true
  end
end
