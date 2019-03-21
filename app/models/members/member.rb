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

    after_save :destroy_family_if_empty

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
