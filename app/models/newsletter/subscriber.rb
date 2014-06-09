module Newsletter
  class Subscriber < BaseModel
    include RandomUniqueAttribute
  
    has_random_unique_token :token
  
    validates :email,
              :presence => true,
              :uniqueness => true,
              :email_format => true
  end
end
