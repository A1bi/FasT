class Members::Member < BaseModel
  has_secure_password

  attr_accessor :email_can_be_blank

  belongs_to :related_to, class_name: 'Members::Member', optional: true
  has_many :related_members, class_name: 'Members::Member',
                             foreign_key: :related_to_id,
                             inverse_of: :related_to,
                             dependent: :nullify

  validates :email, :presence => true, :if => Proc.new { |member| !member.email_can_be_blank }

  validates :email,
            :allow_blank => true,
            :uniqueness => true,
            :email_format => true

  validates :password,
            :length => { :minimum => 6 },
            :if => :password_digest_changed?

  validates_presence_of :first_name, :last_name

  validate :cannot_be_related_to_themselves
  validate :either_related_members_or_related_to

  enum group: [:member, :admin]

  def self.alphabetically
    order(:last_name, :first_name)
  end

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

  def either_related_members_or_related_to
    return unless related_to.present? && related_members.any?
    errors.add(:base, :either_related_members_or_related_to)
  end

  def cannot_be_related_to_themselves
    errors.add(:related_to, :cannot_be_themselves) if related_to == self
  end
end
