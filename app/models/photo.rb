class Photo < BaseModel
  has_attached_file :image, styles: { thumb: "145x145#", big: "600" }, only_process: [:thumb, :big, :original]

  validates_attachment :image, presence: true, content_type: { content_type: /\Aimage\/(jpe?g|png)\z/ }

  belongs_to :gallery, touch: true
end
