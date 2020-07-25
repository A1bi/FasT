# frozen_string_literal: true

class AddEntranceToTicketingBlocks < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_blocks, :entrance, :string
  end
end
