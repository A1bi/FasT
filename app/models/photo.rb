class Photo < BaseModel
  attr_accessible :gallery_id, :position, :text, :image
  has_attached_file :image,
		:styles => { :thumb => "145x145#", :big => "600", :slide => "500" },
		:only_process => [:thumb, :big]
  
  validates :image, :attachment_presence => true
  
  belongs_to :gallery, :touch => true
	
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
