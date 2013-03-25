class Members::Member < ActiveRecord::Base
	attr_accessible
	attr_accessible :email, :password, :password_confirmation, :as => :member
	attr_accessible :email, :first_name, :last_name, :nickname, :group, :birthday, :as => :admin
	has_secure_password
	
	attr_accessor :email_can_be_blank
	
	validates :email, :presence => true, :if => Proc.new { |member| !member.email_can_be_blank }
	
  validates :email,
						:allow_blank => true,
            :uniqueness => true,
            :email_format => true
            
  validates :password,
            :length => { :minimum => 6 },
						:if => :password_digest_changed?
						
	validates_presence_of :first_name, :last_name
	
	def nickname
		super.presence || self.first_name
	end
            
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
	
	def reset_password
		self.set_random_password
		self.set_activation_code
	end
	
	def send_activation_mail
		if self.email.present?
			MemberMailer.activation(self).deliver
			return true
		end
		false
	end
	
	private
	
	def self.groups
		{1 => :member, 2 => :admin}
	end
	
	def self.random_hash
		SecureRandom.hex(16)
	end
end
