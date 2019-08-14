class ChangePhotoTextDataType < ActiveRecord::Migration[5.2]
  def up
    change_column :photos, :text, :text
  end

  def down
    change_column :photos, :text, :string
  end
end
