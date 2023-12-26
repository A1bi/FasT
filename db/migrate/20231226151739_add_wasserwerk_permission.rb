# frozen_string_literal: true

class AddWasserwerkPermission < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    execute <<~SQL.squish
      ALTER TYPE permission ADD VALUE 'wasserwerk_read';
      ALTER TYPE permission ADD VALUE 'wasserwerk_update';
    SQL
  end
end
