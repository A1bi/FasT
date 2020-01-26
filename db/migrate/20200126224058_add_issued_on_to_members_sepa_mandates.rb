class AddIssuedOnToMembersSepaMandates < ActiveRecord::Migration[6.0]
  def change
    add_column :members_sepa_mandates, :issued_on, :date

    reversible do |dir|
      dir.up do
        execute 'UPDATE members_sepa_mandates SET issued_on = \'1970-01-01\''
      end
    end

    change_column_null :members_sepa_mandates, :issued_on, false
  end
end
