# frozen_string_literal: true

class CreateDoorkeeperTables < ActiveRecord::Migration[7.0]
  def change
    create_table :oauth_applications do |t|
      t.string :name, null: false
      t.string :uid, null: false, index: { unique: true }
      t.string :secret, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: ''
      t.boolean :confidential, null: false, default: true
      t.timestamps null: false
    end

    create_table :oauth_access_grants do |t|
      t.references :resource_owner, null: false
      t.references :application, null: false
      t.string :token, null: false, index: { unique: true }
      t.integer :expires_in, null: false
      t.text :redirect_uri, null: false
      t.string :scopes, null: false, default: ''
      t.datetime :created_at, null: false
      t.datetime :revoked_at
    end

    create_table :oauth_access_tokens do |t|
      t.references :resource_owner, index: true
      t.references :application, null: false
      t.string :token, null: false, index: { unique: true }

      t.string :refresh_token, index: { unique: true }
      t.integer :expires_in
      t.string :scopes
      t.datetime :created_at, null: false
      t.datetime :revoked_at
    end

    add_foreign_key :oauth_access_tokens, :oauth_applications, column: :application_id
    add_foreign_key :oauth_access_tokens, :users, column: :resource_owner_id
    add_foreign_key :oauth_access_grants, :oauth_applications, column: :application_id
    add_foreign_key :oauth_access_grants, :users, column: :resource_owner_id
  end
end
