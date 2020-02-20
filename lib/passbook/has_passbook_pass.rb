module Passbook
  module HasPassbookPass
    extend ActiveSupport::Concern

    class_methods do
      def has_passbook_pass(options = {}) # rubocop:disable Naming/PredicateName
        has_one (options[:attribute] || :passbook_pass),
                class_name: 'Passbook::Models::Pass',
                as: :assignable, dependent: :destroy

        before_update :update_passbook_pass

        include LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def passbook_pass(create: false)
        if super().blank? && create
          type_id = Settings.passbook.pass_type_ids[model_name.i18n_key]
          create_passbook_pass(type_id: type_id)
        end
        super()
      end

      def update_passbook_pass
        passbook_pass.touch if passbook_pass.present?
      end
    end
  end
end

ActiveRecord::Base.include Passbook::HasPassbookPass
