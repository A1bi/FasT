class AddStrippedPlanDigestToTicketingSeatings < ActiveRecord::Migration[5.2]
  def change
    add_column :ticketing_seatings, :stripped_plan_digest, :string

    reversible do |dir|
      dir.up do
        Ticketing::Seating.find_each(&:save)
      end
    end
  end
end
