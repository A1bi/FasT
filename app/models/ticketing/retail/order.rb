class Ticketing::Retail::Order < ActiveRecord::Base
  has_one :bunch, :class_name => Ticketing::Bunch, :as => :assignable, :validate => true
  belongs_to :store
  
  validates_presence_of :bunch, :store
end
