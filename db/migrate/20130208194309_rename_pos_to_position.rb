class RenamePosToPosition < ActiveRecord::Migration
  def change
		[:photos, :galleries].each do |column|
			rename_column column, :pos, :position
		end
  end
end
