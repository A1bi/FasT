# frozen_string_literal: true

require_shared_examples 'ticketing/orders'

RSpec.describe Ticketing::Retail::Order do
  it_behaves_like 'generic order', :retail_order

  it { is_expected.to belong_to(:store) }
end
