class AddMembershipTermination < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :membership_terminates_on, :date
  end
end
