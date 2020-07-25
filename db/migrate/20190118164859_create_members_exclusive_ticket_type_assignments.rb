# frozen_string_literal: true

class CreateMembersExclusiveTicketTypeAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :members_exclusive_ticket_type_credits do |t|
      t.belongs_to :ticket_type
      t.integer :value
      t.timestamps
    end

    create_table :members_exclusive_ticket_type_credit_spendings do |t|
      t.belongs_to :member, index: { name: :index_members_exclusive_ticket_type_credit_spndngs_on_member }
      t.belongs_to :ticket_type, index: { name: :index_members_exclusive_ticket_type_credit_spndngs_on_type }
      t.belongs_to :order, index: { name: :index_members_exclusive_ticket_type_credit_spndngs_on_order }
      t.integer :value
      t.timestamps
    end
  end
end
