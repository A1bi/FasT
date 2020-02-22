# frozen_string_literal: true

module RandomUniqueAttribute
  extend ActiveSupport::Concern

  module ClassMethods
    # rubocop:disable Naming/PredicateName
    def has_random_unique_number(attr, min: 0, max:)
      max -= min
      set_attr attr do
        min + SecureRandom.random_number(max)
      end
    end

    def has_random_unique_token(attr, length = nil)
      length /= 2 if length
      set_attr attr do
        SecureRandom.hex(length)
      end
    end
    # rubocop:enable Naming/PredicateName

    protected

    def set_attr(attr, &block)
      before_validation on: :create do |record|
        loop do
          record[attr] = block.call
          break unless self.class.exists?(attr => record[attr])
        end
      end
    end
  end
end
