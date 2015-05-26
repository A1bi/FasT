module RandomUniqueAttribute
  extend ActiveSupport::Concern

  module ClassMethods
    def has_random_unique_number(attr, digits)
      min = 10 ** (digits - 1)
      max = 10 ** digits - min
      set_attr attr do
        min + SecureRandom.random_number(max)
      end
    end
    
    def has_random_unique_token(attr, length = nil)
      length = length / 2 if length
      set_attr attr do
        SecureRandom.hex length
      end
    end
    
    protected
    
    def set_attr(attr, &block)
      before_validation on: :create do |record|
        begin
          record[attr] = block.call
        end while self.class.exists?(attr => record[attr])
      end
    end
  end
end
