# frozen_string_literal: true

class CreateMembersSepaMandates < ActiveRecord::Migration[6.0]
  def change
    create_table :members_sepa_mandates do |t|
      t.string :debtor_name
      t.string :iban, limit: 34
      t.integer :number

      t.timestamps
    end

    add_reference :users, :sepa_mandate, foreign_key: { to_table: :members_sepa_mandates }
  end
end
