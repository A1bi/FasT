# frozen_string_literal: true

class WebAuthnCredential < ApplicationRecord
  belongs_to :user

  validates :public_key, presence: true
end
