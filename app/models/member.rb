class Member < ActiveRecord::Base
  attr_accessible :email, :first_name, :group, :group_name, :last_name, :password, :password_confirmation
	has_secure_password
	
  validates :email,
            :presence => true,
            :uniqueness => true,
            :format => { :with => /^([a-z0-9-]+\.?)+@([a-z0-9-]+\.)+[a-z]{2,9}$/i }
            
  validates :password,
            :length => { :minimum => 6 },
            :on => :create
            
	def group_name
		self.class.groups[self.group] || :none
	end
	
	def group_name=(name)
		self.group = self.class.groups.invert[name]
	end
  
  def admin?
    self.group_name == :admin
  end
	
	private
	def self.groups
		{1 => :member, 2 => :admin}
	end
end
