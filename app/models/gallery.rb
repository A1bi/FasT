class Gallery < BaseModel
  has_many :photos, -> { order(:position) }, dependent: :destroy,
                                             inverse_of: :gallery

  validates :title, presence: true
end
