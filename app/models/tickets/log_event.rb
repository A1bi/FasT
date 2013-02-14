class Tickets::LogEvent < ActiveRecord::Base
  serialize :info
	
	belongs_to :member
	belongs_to :loggable, :polymorphic => true
end
