module Newsletter
  class Subscriber < BaseModel
    include RandomUniqueAttribute

    has_random_unique_token :token
    belongs_to :subscriber_list

    auto_strip_attributes :last_name, squish: true

    validates :email,
              presence: true,
              uniqueness: { case_sensitive: false },
              email_format: true

    validates :privacy_terms, acceptance: true

    def self.confirmed
      where.not(confirmed_at: nil)
    end

    def confirmed?
      confirmed_at.present?
    end

    def confirm!
      self.confirmed_at = Time.now
      save
    end

    def send_confirmation_instructions(after_order: false, delay: nil)
      return if new_record?

      NewsletterMailer.confirmation_instructions(self, after_order: after_order).deliver_later(wait: delay)
    end
  end
end
