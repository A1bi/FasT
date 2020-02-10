module UserExtensions
  def retail_store?
    is_a? Ticketing::Retail::User
  end
end

User.send(:include, UserExtensions)

module Ticketing
  module Retail
    class User < ::User
      belongs_to :store, foreign_key: :ticketing_retail_store_id,
                         inverse_of: :users
    end
  end
end
