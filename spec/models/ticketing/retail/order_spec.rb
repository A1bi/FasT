# frozen_string_literal: true

require_shared_examples 'ticketing/orders'

RSpec.describe Ticketing::Retail::Order do
  it_behaves_like 'generic order', :retail_order

  it { is_expected.to belong_to(:store) }

  describe 'validations' do
    subject { build(:retail_order, store:) }

    let(:store) { build(:retail_store) }

    context 'when sale is disabled for store' do
      let(:store) { build(:retail_store, :sale_disabled) }

      it 'has an error on the store' do
        subject.valid?
        expect(subject.errors).to be_added(:store, 'has sale disabled')
      end
    end

    context 'when sale is enabled for store' do
      it 'does not have an error on the store' do
        subject.valid?
        expect(subject.errors).not_to be_added(:store)
      end
    end
  end
end
