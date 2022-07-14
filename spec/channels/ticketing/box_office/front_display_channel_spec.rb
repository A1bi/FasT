# frozen_string_literal: true

RSpec.describe Ticketing::BoxOffice::FrontDisplayChannel do
  before { stub_connection }

  describe '#subscribed' do
    subject do
      subscribe(box_office_id:)
      subscription
    end

    context 'with a valid box office id' do
      let(:box_office) { create(:box_office) }
      let(:box_office_id) { box_office.id }

      it { is_expected.to have_stream_for(box_office) }
    end

    context 'with an invalid box office id' do
      let(:box_office_id) { 'foo' }

      it { is_expected.to be_rejected }
    end
  end
end
