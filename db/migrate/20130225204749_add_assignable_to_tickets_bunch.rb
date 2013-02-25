class AddAssignableToTicketsBunch < ActiveRecord::Migration
  def change
    add_column :tickets_bunches, :assignable_id, :integer
    add_column :tickets_bunches, :assignable_type, :string
  end
end
