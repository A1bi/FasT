# frozen_string_literal: true

class CreateWebAuthnCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :web_authn_credentials, id: :string do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.binary :public_key, null: false
      t.string :aaguid
      t.integer :sign_count, default: 0, null: false
      t.timestamps
    end

    add_column :users, :webauthn_id, :string
  end
end
