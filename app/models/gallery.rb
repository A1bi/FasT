class Gallery < BaseModel
  has_many :photos, -> { order(:position) }, :dependent => :destroy

  validates :title, :presence => true
end
