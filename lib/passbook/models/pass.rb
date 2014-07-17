module Passbook
  module Models
    class Pass < ActiveRecord::Base
      belongs_to :assignable, polymorphic: true
      has_many :registrations, dependent: :destroy
      has_many :devices, through: :registrations

      validates_presence_of :type_id, :serial_number, :auth_token
  
      after_destroy :delete_file
  
      def path(full = false)
        File.join(Passbook.options[full ? :full_path : :path], filename)
      end
  
      private
  
      def delete_file
        FileUtils.rm(path(true), force: true)
      end
    end
  end
end