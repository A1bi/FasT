# frozen_string_literal: true

module Passbook
  module HasPassbookPass
    extend ActiveSupport::Concern

    class_methods do
      def has_passbook_pass(options = {}) # rubocop:disable Naming/PredicatePrefix
        has_one (options[:attribute] || :passbook_pass),
                class_name: 'Passbook::Models::Pass',
                as: :assignable, dependent: :destroy

        before_update :update_passbook_pass

        include LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def passbook_pass(create: false)
        return super() unless super().nil? && create

        create_passbook_pass
      end

      def update_passbook_pass
        passbook_pass.presence&.update_file
      end
    end
  end
end

ActiveSupport.on_load(:active_record) { include Passbook::HasPassbookPass }
