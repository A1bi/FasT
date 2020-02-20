module Ticketing
  module Retail
    class Store < ApplicationRecord
      include Ticketing::Billable

      has_many :orders, dependent: :nullify
      has_many :users, dependent: :destroy,
                       foreign_key: :ticketing_retail_store_id,
                       inverse_of: :store
    end
  end
end
