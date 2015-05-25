class Ticketing::Retail::Store < BaseModel
  include Ticketing::Billable

  has_many :orders
  has_secure_password

  validates_length_of :password, minimum: 6, if: :password_digest_changed?
end
