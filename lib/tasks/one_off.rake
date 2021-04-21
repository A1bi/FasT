# frozen_string_literal: true

namespace :one_off do
  task run: :environment do
    Ticketing::Billing::Transaction.where(note_key: :purchased_coupon)
                                   .each do |transaction|
      transaction.update(created_at: transaction.account.billable.created_at,
                         updated_at: transaction.account.billable.updated_at)
    end
  end
end
