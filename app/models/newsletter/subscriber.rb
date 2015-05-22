module Newsletter
  class Subscriber < BaseModel
    include RandomUniqueAttribute

    has_random_unique_token :token

    validates :email,
              :presence => true,
              :uniqueness => { :case_sensitive => false },
              :email_format => true
  end
end
