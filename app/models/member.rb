class Member < ActiveRecord::Base
  attr_accessible :email, :first_name, :group, :last_login, :last_name, :password, :password_confirmation
  
  has_secure_password
  
  validates :email,
            :presence => true,
            :uniqueness => true,
            :format => { :with => /^([a-z0-9-]+\.?)+@([a-z0-9-]+\.)+[a-z]{2,9}$/i }
            
  validates :password,
            :length => { :minimum => 6 },
            :on => :create
  
  def admin?
    self.group == 2
  end
end
