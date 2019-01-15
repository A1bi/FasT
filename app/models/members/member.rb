class Members::Member < BaseModel
  has_secure_password

  attr_accessor :email_can_be_blank
  attr_reader :family_member_id

  belongs_to :family, optional: true

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

  after_save :destroy_family_if_empty

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

  def in_family?
    family.present?
  end

  def add_to_family_with_member(member)
    if !member.in_family?
      member.family = Members::Family.create
      member.save
    end
    self.family = member.family
  end

  def family_member_id=(member_id)
    return if member_id.blank?
    add_to_family_with_member(self.class.find(member_id))
  end

  private

  def self.random_hash
    SecureRandom.hex
  end

  def destroy_family_if_empty
    return unless saved_change_to_family_id? && family_id_before_last_save.present?
    old_fam = Members::Family.find(family_id_before_last_save)
    old_fam.destroy_if_empty
  end
end
