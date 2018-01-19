class Members::Member < BaseModel
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

  enum group: [:member, :admin]

  def nickname
    super.presence || self.first_name
  end

  def full_name
    self.first_name + " " + self.last_name
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

  private

  def self.random_hash
    SecureRandom.hex
  end
end
