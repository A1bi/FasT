# frozen_string_literal: true

require_shared_examples 'ticketing/orders'

RSpec.describe Ticketing::Order do
  it_behaves_like 'generic order'
end
