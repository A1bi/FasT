class Members::File < ActiveRecord::Base
  attr_accessible :description, :path, :title
	
	validates_presence_of :path
end
