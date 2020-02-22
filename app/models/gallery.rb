# frozen_string_literal: true

class Gallery < ApplicationRecord
  has_many :photos, -> { order(:position) }, dependent: :destroy,
                                             inverse_of: :gallery

  validates :title, presence: true
end
