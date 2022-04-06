# frozen_string_literal: true

RSpec.describe Ticketing::LogEvent do
  describe 'associations' do
    it { is_expected.to belong_to(:loggable) }
    it { is_expected.to belong_to(:user).optional(true) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:action) }
  end

  describe '#info' do
    subject { event.info }

    let(:event) { build(:log_event, info:) }

    context 'when info column is NULL' do
      let(:info) { nil }

      it { is_expected.to eq({}) }
    end

    context 'when info is present' do
      let(:info) { { 'foo' => 'bar', bar: 'foo' } }

      it { is_expected.to eq(foo: 'bar', bar: 'foo') }
    end
  end
end
