class RemoveRemnantsOfOldSeating < ActiveRecord::Migration[5.2]
  def change
    remove_column :ticketing_blocks, :color, :string
    remove_column :ticketing_seats, :position_x, :integer
    remove_column :ticketing_seats, :position_y, :integer
    remove_column :ticketing_seatings, :underlay_filename, :string
  end
end
