# frozen_string_literal: true

require_shared_examples 'anonymizable'

RSpec.describe Ticketing::BankTransaction do
  it_behaves_like 'anonymizable', %i[name iban] do
    let(:record) { create(:bank_transaction) }
    let(:records) { create_list(:bank_transaction, 2) }
  end
end
