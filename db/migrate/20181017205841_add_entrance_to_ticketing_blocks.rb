class AddEntranceToTicketingBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_blocks, :entrance, :string
  end
end
