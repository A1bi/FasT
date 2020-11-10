# frozen_string_literal: true

require_shared_examples 'ticketing/orders'

RSpec.describe Ticketing::BoxOffice::Order do
  it_behaves_like 'generic order'

  it { is_expected.to belong_to(:box_office) }
end
