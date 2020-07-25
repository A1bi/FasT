# frozen_string_literal: true

class AddUserType < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    execute "ALTER TYPE user_type ADD VALUE 'Ticketing::Retail::User'"
  end
end
