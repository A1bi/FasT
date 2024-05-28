# frozen_string_literal: true

module Cmxl
  module Fields
    module TransactionExtensions
      def sha
        # use source and details source because source alone might not be unique within the same statement
        Digest::SHA2.new.update("#{source}#{details&.source}").to_s
      end
    end

    Transaction.prepend TransactionExtensions
  end
end
