class Newsletter::Image < BaseModel
  belongs_to :newsletter

  has_attached_file :image, styles: { thumb: "145x145#", big: "1000", mail: "275" }

  validates_attachment :image, presence: true, content_type: { content_type: /\Aimage\/(jpe?g|png)\z/ }
end
