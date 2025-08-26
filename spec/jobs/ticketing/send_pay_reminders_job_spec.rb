# frozen_string_literal: true

require 'support/time'

RSpec.describe Ticketing::SendPayRemindersJob do
  describe '#perform_now' do
    subject do
      travel_to(first_run_at) { described_class.perform_now }
      travel_to(second_run_at) { described_class.perform_now }
    end

    def create_affected_order(*)
      create(:web_order, :complete, :unpaid, :transfer_payment, *)
    end

    let(:due_order) { create_affected_order(created_at: 8.days.ago) }
    let(:due_order_with_first_reminder) do
      create_affected_order(created_at: 8.days.ago, last_pay_reminder_sent_at: 1.day.ago)
    end
    let(:not_yet_due_order) { create_affected_order(created_at: 5.days.ago) }
    let(:overdue_order) { create_affected_order(created_at: 11.days.ago) }
    let(:overdue_order_with_first_reminder) do
      create_affected_order(created_at: 12.days.ago, last_pay_reminder_sent_at: 5.days.ago)
    end
    let(:first_run_at) { Time.current.round }
    let(:second_run_at) { 3.days.from_now.round }

    before do
      create(:web_order, :complete)
      create_affected_order
      create_affected_order(:cash_payment, created_at: 8.days.ago)
      create_affected_order(created_at: 8.days.ago, email: nil)
      create_affected_order(created_at: 14.days.ago, last_pay_reminder_sent_at: 2.days.ago)
      create(:retail_order, :complete, :unpaid)
    end

    it 'schedules mail delivery only for eligible orders' do # rubocop:disable RSpec/ExampleLength
      expect { subject }.to(
        have_enqueued_mail(Ticketing::OrderMailer, :pay_reminder).exactly(6)
        .and(have_enqueued_mail(Ticketing::OrderMailer, :pay_reminder).twice
             .with(a_hash_including(params: { order: due_order })))
        .and(have_enqueued_mail(Ticketing::OrderMailer, :pay_reminder).once
             .with(a_hash_including(params: { order: due_order_with_first_reminder })))
        .and(have_enqueued_mail(Ticketing::OrderMailer, :pay_reminder).once
            .with(a_hash_including(params: { order: not_yet_due_order })))
        .and(have_enqueued_mail(Ticketing::OrderMailer, :pay_reminder).once
            .with(a_hash_including(params: { order: overdue_order })))
        .and(have_enqueued_mail(Ticketing::OrderMailer, :pay_reminder).once
            .with(a_hash_including(params: { order: overdue_order_with_first_reminder })))
      )
    end

    it 'updates last pay reminder timestamp' do
      expect { subject }.to(
        change { due_order.reload.last_pay_reminder_sent_at }.to(second_run_at)
        .and(change { due_order_with_first_reminder.reload.last_pay_reminder_sent_at }.to(second_run_at))
        .and(change { overdue_order.reload.last_pay_reminder_sent_at }.to(first_run_at))
      )
    end
  end
end
