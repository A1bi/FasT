module Ticketing::BoxOffice
  class BoxOffice < BaseModel
    has_many :purchases, dependent: :destroy
  end
end