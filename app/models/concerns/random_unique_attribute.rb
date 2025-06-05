# frozen_string_literal: true

module RandomUniqueAttribute
  extend ActiveSupport::Concern

  module ClassMethods
    # rubocop:disable Naming/PredicatePrefix
    def has_random_unique_number(attr, max:, min: 0)
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
    # rubocop:enable Naming/PredicatePrefix

    protected

    def set_attr(attr, &block)
      before_validation on: :create do |record|
        next if record[attr].present? || record.persisted?

        loop do
          record[attr] = block.call
          break unless self.class.base_class.exists?(attr => record[attr])
        end
      end
    end
  end
end
