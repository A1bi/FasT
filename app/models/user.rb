# frozen_string_literal: true

class User < ApplicationRecord
  PERMISSIONS = %i[permissions_read permissions_update
                   members_read members_update members_destroy
                   newsletters_read newsletters_update newsletters_approve
                   internet_access_sessions_create
                   ticketing_events_read ticketing_events_update
                   wasserwerk_read wasserwerk_update].freeze

  has_secure_password
  has_person_name

  has_many :log_events, class_name: 'Ticketing::LogEvent', dependent: :nullify
  has_many :web_authn_credentials, dependent: :destroy

  # rubocop:disable Rails/InverseOf
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant', foreign_key: :resource_owner_id,
                           dependent: :delete_all
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken', foreign_key: :resource_owner_id,
                           dependent: :delete_all
  # rubocop:enable Rails/InverseOf

  enum :group, { member: 0, admin: 1 }, integer_column: true

  generates_token_for(:activation, expires_in: 1.week) { last_login }
  generates_token_for(:password_reset, expires_in: 15.minutes) { password_salt.last(10) }

  validates :email, presence: true, on: :user_update
  validates :email, allow_blank: true, uniqueness: { case_sensitive: false }, email_format: true
  validates :password, length: { minimum: 6 }, if: :password_digest_changed?

  before_create :set_random_password

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
    super(email.presence)
  end

  def logged_in
    self.last_login = Time.current
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

  def web_authn_required?
    web_authn_credentials.any?
  end

  private

  def set_random_password
    self.password ||= SecureRandom.hex
  end
end
