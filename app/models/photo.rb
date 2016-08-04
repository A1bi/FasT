class Photo < BaseModel
  has_attached_file :image, styles: { thumb: "145x145#", big: "600", slide: "500" }, only_process: [:thumb, :big]

  validates_attachment :image, presence: true, content_type: { content_type: /\Aimage\/(jpe?g|png)\z/ }

  belongs_to :gallery, touch: true

  def self.slides
    where(is_slide: true)
  end

  def slide?
    self.is_slide
  end

  def toggle_slide
    update_attribute(:is_slide, !slide?)
    image.reprocess!(:slide) if slide? && !File.exists?(image.path(:slide))
  end
end
