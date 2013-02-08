class Gallery < ActiveRecord::Base
  attr_accessible :disclaimer, :position, :title
  
  has_many :photos, :order => :position, :dependent => :destroy
  
  validates :title, :presence => true
end
