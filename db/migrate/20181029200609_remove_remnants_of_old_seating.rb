# frozen_string_literal: true

class RemoveRemnantsOfOldSeating < ActiveRecord::Migration[6.0]
  def change
    remove_column :ticketing_blocks, :color, :string
    remove_column :ticketing_seatings, :underlay_filename, :string
    # rubocop:disable Rails/BulkChangeTable
    remove_column :ticketing_seats, :position_x, :integer
    remove_column :ticketing_seats, :position_y, :integer
    # rubocop:enable Rails/BulkChangeTable
  end
end
