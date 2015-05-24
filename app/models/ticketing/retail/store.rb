class Ticketing::Retail::Store < BaseModel
  include Billable

  has_many :orders
  has_secure_password

  validates_length_of :password, minimum: 6, if: :password_digest_changed?

  before_create :create_billing_account
end
