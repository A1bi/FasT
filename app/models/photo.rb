class Photo < ActiveRecord::Base
  attr_accessible :gallery_id, :position, :text, :image
  has_attached_file :image, :styles => { :thumb => "145x145#", :big => "600" }
  
  validates :image, :attachment_presence => true
  
  belongs_to :gallery, :touch => true
end
