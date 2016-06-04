module Ticketing
  class SigningKey < BaseModel
    @@minimum_number_of_keys = 5
    @@secret_length = 32
    
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
      @verifier.generate({ k: id, d: data }).tr("+/=", "~_,")
    end
    
    def self.verify(signed)
      signed = signed.tr("~_,", "+/=")
      parts = signed.split('--')
      data = JSON.parse(Base64.decode64(parts[0]))
      key = find(data['k'])
      data = key.verify(signed)
      data['d'].deep_symbolize_keys if data
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