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

  class << self
    def alphabetically
      order(:last_name, :first_name)
    end

    private

    def random_hash
      SecureRandom.hex
    end
  end

  def nickname
    super.presence || first_name
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
    set_random_password
    set_activation_code
  end
end
