module Newsletter
  class Subscriber < BaseModel
    include RandomUniqueAttribute

    has_random_unique_token :token
    
    auto_strip_attributes :last_name, squish: true

    validates :email,
              :presence => true,
              :uniqueness => { :case_sensitive => false },
              :email_format => true
  end
end
