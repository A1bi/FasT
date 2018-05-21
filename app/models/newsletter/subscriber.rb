module Newsletter
  class Subscriber < BaseModel
    include RandomUniqueAttribute

    has_random_unique_token :token
    belongs_to :subscriber_list

    auto_strip_attributes :last_name, squish: true

    validates :email,
              :presence => true,
              :uniqueness => { :case_sensitive => false },
              :email_format => true

    validates :privacy_terms, acceptance: true

    def self.consented
      where.not(consented_at: nil)
    end

    def consented?
      consented_at.present?
    end

    def consent!
      self.consented_at = Time.now
      save
    end
  end
end
