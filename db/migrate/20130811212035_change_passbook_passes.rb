class ChangePassbookPasses < ActiveRecord::Migration
  def change
    add_column :passbook_passes, :assignable_id, :integer
    add_column :passbook_passes, :assignable_type, :string
    rename_column :passbook_passes, :path, :filename
  end
end
