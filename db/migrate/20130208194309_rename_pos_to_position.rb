# frozen_string_literal: true

class RenamePosToPosition < ActiveRecord::Migration[6.0]
  def change
    %i[photos galleries].each do |column|
      rename_column column, :pos, :position
    end
  end
end
