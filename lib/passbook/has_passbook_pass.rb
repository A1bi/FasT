module Passbook
  module HasPassbookPass
    extend ActiveSupport::Concern

    module ClassMethods
      def has_passbook_pass(options = {})
        has_one (options[:attribute] || :passbook_pass),
                class_name: 'Passbook::Models::Pass',
                as: :assignable, dependent: :destroy

        after_save :save_passbook_pass

        include Passbook::HasPassbookPass::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def update_passbook_pass(identifier, info)
        @passbook_pass_file = Passbook::Pass.new(identifier, info)

        if passbook_pass.nil?
          build_passbook_pass({ type_id: @passbook_pass_file.info[:passTypeIdentifier] })
        end

        passbook_pass.touch if passbook_pass.persisted?
      end
    end

    private

    def save_passbook_pass
      if @passbook_pass_file.present?
        if passbook_pass.save
          @passbook_pass_file.info[:serialNumber] = passbook_pass.serial_number
          @passbook_pass_file.info[:authenticationToken] = passbook_pass.auth_token
          @passbook_pass_file.save passbook_pass.filename
        else
          return false
        end
      end
    end
  end
end

ActiveRecord::Base.send :include, Passbook::HasPassbookPass
