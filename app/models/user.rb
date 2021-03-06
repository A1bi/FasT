# frozen_string_literal: true

class User < ApplicationRecord
  PERMISSIONS = %i[permissions_read permissions_update members_read
                   members_update members_destroy newsletters_read
                   newsletters_update newsletters_approve
                   internet_access_sessions_create].freeze

  has_secure_password
  has_person_name

  has_many :log_events, class_name: 'Ticketing::LogEvent', dependent: :nullify

  validates :email, presence: true, on: :user_update

  validates :email,
            allow_blank: true,
            uniqueness: { case_sensitive: false },
            email_format: true

  validates :password,
            length: { minimum: 6 },
            if: :password_digest_changed?

  enum group: { member: 0, admin: 1 }, integer_column: true

  def self.alphabetically
    order(:last_name, :first_name)
  end

  def self.find_by_email(email)
    find_by('LOWER(email) = ?', email.downcase)
  end

  def nickname
    super.presence || first_name
  end

  def email=(email)
    # nillify empty emails so database doesn't complain about uniqueness
    super email.presence
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

  def member?
    is_a? Members::Member
  end

  def retail?
    is_a? Ticketing::Retail::User
  end

  def permitted?(permission)
    permissions&.include? permission.to_s
  end

  def authorized_for_shared_email_account?(email)
    shared_email_accounts_authorized_for&.include? email
  end

  private

  def set_random_password
    self.password = random_hash
  end

  def random_hash
    SecureRandom.hex
  end
end
