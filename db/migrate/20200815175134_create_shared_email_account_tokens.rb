# frozen_string_literal: true

class CreateSharedEmailAccountTokens < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'

    create_table :shared_email_account_tokens, id: :uuid do |t|
      t.string :email, null: false
      t.timestamps
    end
  end
end
