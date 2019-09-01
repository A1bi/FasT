module UserExtensions
  def member?
    is_a? Members::Member
  end
end

User.send(:include, UserExtensions)

module Members
  class Member < User
    attr_reader :family_member_id

    belongs_to :family, optional: true
    belongs_to :sepa_mandate, optional: true, validate: true

    auto_strip_attributes :first_name, :last_name, :street, :city, squish: true
    phony_normalize :phone, default_country_code: 'DE'

    validates :joined_at, presence: true
    validates :plz, numericality: { only_integer: true, less_than: 100_000 },
                    allow_blank: true

    after_save :destroy_family_if_empty

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

    private

    def destroy_family_if_empty
      return unless saved_change_to_family_id? && family_id_before_last_save.present?

      old_fam = Members::Family.find(family_id_before_last_save)
      old_fam.destroy_if_empty
    end
  end
end
