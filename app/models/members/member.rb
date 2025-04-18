# frozen_string_literal: true

module Members
  class Member < User
    include HasGender

    attr_reader :family_member_id

    belongs_to :family, optional: true
    belongs_to :sepa_mandate, optional: true, validate: true
    has_many :exclusive_ticket_type_credit_spendings, dependent: :destroy
    has_many :membership_fee_payments, dependent: :destroy
    has_one :membership_application, dependent: :destroy

    auto_strip_attributes :first_name, :last_name, :street, :city, squish: true
    phony_normalize :phone, default_country_code: 'DE'

    validates :first_name, :last_name, :gender, :number, :joined_at, presence: true
    validates :number, uniqueness: true
    validates :membership_fee, numericality: { greater_than_or_equal_to: 0 }
    validates :plz, plz_format: true, allow_blank: true

    after_initialize :set_number
    before_validation :set_joined_at, on: :create
    before_validation :set_default_membership_fee, on: :create
    after_save :destroy_family_if_empty

    class << self
      def new_from_membership_application(application)
        member = new(application.slice(:first_name, :last_name, :gender, :email, :birthday, :phone,
                                       :street, :plz, :city))
        member.sepa_mandate = SepaMandate.new_from_membership_application(application)
        member.membership_application = application
        member
      end

      def membership_cancelled
        where.not(membership_terminates_on: nil)
      end
    end

    def plz
      super.to_s.rjust(5, '0') if super.present?
    end

    def in_family?
      family.present?
    end

    def add_to_family_with_member(member)
      unless member.in_family?
        member.family = Members::Family.create
        member.save
      end
      self.family = member.family
    end

    def family_member_id=(member_id)
      return if member_id.blank?

      add_to_family_with_member(self.class.find(member_id))
    end

    def membership_cancelled?
      membership_terminates_on.present?
    end

    def membership_fee_paid?
      membership_fee_paid_until.present? && !membership_fee_paid_until.past?
    end

    def renew_membership!
      return if membership_fee_paid? || membership_cancelled?

      payment = membership_fee_payments.create(
        amount: membership_fee,
        paid_until: next_membership_fee_paid_until
      )

      update(membership_fee_paid_until: payment.paid_until)
    end

    def terminate_membership!
      update(membership_terminates_on: membership_fee_paid_until)
    end

    def revert_membership_termination!
      update(membership_terminates_on: nil)
    end

    private

    def set_number
      self.number = (self.class.maximum(:number) || 0) + 1 unless persisted?
    end

    def set_joined_at
      self.joined_at ||= Time.current
    end

    def set_default_membership_fee
      self.membership_fee ||= Settings.members.default_membership_fee
    end

    def destroy_family_if_empty
      return unless saved_change_to_family_id? && family_id_before_last_save.present?

      Members::Family.find(family_id_before_last_save).destroy_if_empty
    end

    def next_membership_fee_paid_until
      (membership_fee_paid_until || Time.zone.yesterday) + Settings.members.membership_renewal_after_months.months
    end
  end
end
