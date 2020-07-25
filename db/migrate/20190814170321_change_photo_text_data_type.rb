# frozen_string_literal: true

class ChangePhotoTextDataType < ActiveRecord::Migration[6.0]
  def up
    change_column :photos, :text, :text
  end

  def down
    change_column :photos, :text, :string
  end
end
