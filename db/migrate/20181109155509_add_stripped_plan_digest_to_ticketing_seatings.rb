# frozen_string_literal: true

class AddStrippedPlanDigestToTicketingSeatings < ActiveRecord::Migration[6.0]
  def change
    add_column :ticketing_seatings, :stripped_plan_digest, :string
  end
end
