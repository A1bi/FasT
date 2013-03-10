class AddActivationCodeToMembers < ActiveRecord::Migration
  def change
		add_column :members, :activation_code, :string
  end
end
