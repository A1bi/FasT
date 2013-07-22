class Ticketing::LogEvent < ActiveRecord::Base
  serialize :info
	
	belongs_to :member, class_name: Members::Member
	belongs_to :loggable, polymorphic: true
  
  before_create :update_member
  @@member = nil
  
  def self.set_logging_member(member)
    @@member = member
  end
  
  private
  
  def update_member
    self[:member_id] = @@member.id if @@member
  end
end
