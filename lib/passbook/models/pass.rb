module Passbook
  module Models
    class Pass < ActiveRecord::Base
      include RandomUniqueAttribute
      
      belongs_to :assignable, polymorphic: true
      has_many :registrations, dependent: :destroy
      has_many :devices, through: :registrations
      has_random_unique_token :serial_number, 10

      validates_presence_of :type_id, :serial_number, :auth_token, :filename
      
      after_initialize :init
      before_validation :set_filename, on: :create
      after_commit :delete_file, on: :destroy
      
      def init
        self.auth_token ||= SecureRandom.hex
      end
  
      def path(full = false)
        File.join(Passbook.options[full ? :full_path : :path], filename)
      end
  
      private
      
      def set_filename
        if filename.blank?
          self.filename = "pass-#{Digest::SHA1.hexdigest(serial_number + auth_token)}.pkpass"
        end
      end
  
      def delete_file
        FileUtils.rm(path(true), force: true)
      end
    end
  end
end