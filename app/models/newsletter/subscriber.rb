module Newsletter
  class Subscriber < ActiveRecord::Base
    include RandomUniqueAttribute
    
    attr_accessible :email, :last_name, :gender
  
    has_random_unique_token :token
  
    validates :email,
              :presence => true,
              :uniqueness => true,
              :email_format => true
  end
end
