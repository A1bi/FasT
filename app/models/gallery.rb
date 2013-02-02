class Gallery < ActiveRecord::Base
  attr_accessible :disclaimer, :pos, :title
  
  has_many :photos, :order => :pos, :dependent => :destroy
  
  validates :title, :presence => true
end
