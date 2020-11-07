# frozen_string_literal: true

class AddPlanAttachmentToTicketingSeatings < ActiveRecord::Migration[6.0]
  def change
    add_attachment :ticketing_seatings, :plan
    remove_column :ticketing_seatings, :stripped_plan_digest, :string
  end
end
