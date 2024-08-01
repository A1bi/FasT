# frozen_string_literal: true

require_shared_examples 'ticketing/orders'
require_shared_examples 'anonymizable'

RSpec.describe Ticketing::BoxOffice::Order do
  it_behaves_like 'generic order', :box_office_order
  it_behaves_like 'non-anonymizable order', :box_office_order

  it { is_expected.to belong_to(:box_office) }
end
