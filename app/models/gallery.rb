class Gallery < ActiveRecord::Base
  attr_accessible :disclaimer, :pos, :title
  
  has_many :photos, :order => :pos
  
  validates :title, :presence => true
end
