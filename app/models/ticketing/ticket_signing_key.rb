module Ticketing
  class TicketSigningKey < BaseModel
    @@minimum_number_of_keys = 5
    @@secret_length = 32
    
    has_many :tickets, foreign_key: :signing_key_id
    attr_readonly :secret

    validates_presence_of :secret
    validates :active, inclusion: [true, false]
    
    after_initialize :after_initialize

    def self.random_active
      (@@minimum_number_of_keys - count).times do
        create
      end

      where(active: true).offset(rand(count)).first
    end
    
    def sign(data)
      @verifier.generate(data) + "--" + id.to_s
    end
    
    def verify(data)
      @verifier.verify(data)
    end

    private

    def after_initialize
      if new_record?
        self[:active] = true
        self[:secret] = SecureRandom.hex(@@secret_length)
      end
      
      @verifier = ActiveSupport::MessageVerifier.new(self[:secret], serializer: JSON)
    end
  end
end