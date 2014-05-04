class Ticketing::Retail::Store < ActiveRecord::Base
  has_many :orders
  has_secure_password
  validates_length_of :password, minimum: 6, if: :password_digest_changed?
end
