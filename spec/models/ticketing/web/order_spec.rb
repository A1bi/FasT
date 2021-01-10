# frozen_string_literal: true

require_shared_examples 'ticketing/orders'
require_shared_examples 'anonymizable'

RSpec.describe Ticketing::Web::Order do
  it_behaves_like 'generic order', :web_order

  it_behaves_like 'anonymizable', %i[email first_name last_name gender
                                     affiliation phone] do
    let(:record) { create(:web_order, :with_purchased_coupons) }
  end
end
