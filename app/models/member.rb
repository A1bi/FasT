class Member < ActiveRecord::Base
	attr_accessible
	attr_accessible :email, :password, :password_confirmation, :as => :member
	attr_accessible :email, :first_name, :last_name, :group, :as => :admin
	has_secure_password
	
  validates :email,
            :presence => true,
            :uniqueness => true,
            :format => { :with => /^([a-z0-9-]+\.?)+@([a-z0-9-]+\.)+[a-z]{2,9}$/i }
            
  validates :password,
            :length => { :minimum => 6 },
						:if => :password_digest_changed?
            
	def group_name
		self.class.groups[self.group] || :none
	end
	
	def group_name=(name)
		self.group = self.class.groups.invert[name]
	end
  
  def admin?
    self.group_name == :admin
  end
	
	def set_random_password
		self.password = self.class.random_hash
	end
	
	def set_activation_code
		self.activation_code = self.class.random_hash
	end
	
	def activate
		self.activation_code = nil
	end
	
	def logged_in
		self.last_login = Time.zone.now
	end
	
	private
	
	def self.groups
		{1 => :member, 2 => :admin}
	end
	
	def self.random_hash
		SecureRandom.hex(16)
	end
end
