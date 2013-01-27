class Photo < ActiveRecord::Base
  attr_accessible :gallery_id, :pos, :text, :image
  has_attached_file :image, :styles => { :thumb => "145x145#", :big => "600x600>" }
  
  validates :image, :attachment_presence => true
  
  belongs_to :gallery, :touch => true
end
