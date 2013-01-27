class Gallery < ActiveRecord::Base
  attr_accessible :disclaimer, :pos, :title
  
  has_many :photos
end
