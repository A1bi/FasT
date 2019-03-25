class User < BaseModel
  has_secure_password
  has_person_name

  validates :email, presence: true, on: :user_update

  validates :email,
            allow_blank: true,
            uniqueness: true,
            email_format: true

  validates :password,
            length: { minimum: 6 },
            if: :password_digest_changed?

  validates :first_name, :last_name, presence: true

  enum group: %i[member admin]

  def self.alphabetically
    order(:last_name, :first_name)
  end

  def nickname
    super.presence || first_name
  end

  def set_activation_code
    self.activation_code = random_hash
  end

  def activate
    self.activation_code = nil
  end

  def logged_in
    self.last_login = Time.current
  end

  def reset_password
    set_random_password
    set_activation_code
  end

  private

  def set_random_password
    self.password = random_hash
  end

  def random_hash
    SecureRandom.hex
  end
end
