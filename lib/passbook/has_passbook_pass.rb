module Passbook
  module HasPassbookPass
    extend ActiveSupport::Concern
    
    included do
    end
    
    module ClassMethods
      def has_passbook_pass(options = {})
        has_one (options[:attribute] || :passbook_pass), class_name: Passbook::Models::Pass, as: :assignable, dependent: :destroy
        
        include Passbook::HasPassbookPass::LocalInstanceMethods
      end
    end
    
    module LocalInstanceMethods
      def update_passbook_pass(identifier, info)
        pass = Passbook::Pass.new(identifier, info)
        
        if passbook_pass.nil?
          build_passbook_pass({
            type_id: pass.info[:passTypeIdentifier],
            serial_number: pass.info[:serialNumber],
            auth_token: SecureRandom.hex,
            filename: "pass-#{Digest::SHA1.hexdigest(pass.info[:serialNumber].to_s)}#{SecureRandom.hex(4)}.pkpass"
          })
        end
        
        pass.info[:authenticationToken] = passbook_pass.auth_token
        puts passbook_pass.filename
        pass.save passbook_pass.filename
        
        passbook_pass.touch if passbook_pass.persisted?
        passbook_pass.save
      end
    end
  end
end

ActiveRecord::Base.send :include, Passbook::HasPassbookPass