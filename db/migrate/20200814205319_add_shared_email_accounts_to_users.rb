# frozen_string_literal: true

class AddSharedEmailAccountsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :shared_email_accounts_authorized_for, :string,
               array: true
  end
end
