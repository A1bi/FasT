module Passbook
  module Models
    class Pass < BaseModel
      attr_readonly :serial_number, :auth_token, :filename
      attr_writer :file_identifier, :file_info

      belongs_to :assignable, polymorphic: true, optional: true
      has_many :registrations, dependent: :destroy
      has_many :devices, through: :registrations

      validates_presence_of :type_id, :serial_number, :auth_token, :filename

      after_initialize :init
      after_save :save_pass_file
      after_commit :delete_file, on: :destroy

      def init
        self.serial_number ||= SecureRandom.hex(10)
        self.auth_token ||= SecureRandom.hex
        self.filename ||= "pass-#{Digest::SHA1.hexdigest(serial_number + auth_token)}.pkpass"
      end

      def file_path
        path = File.join(Passbook.options[:path], filename)
        save_pass_file unless File.exist?(path)
        path
      end

      def touch
        super
        save_pass_file
        push
      end

      def push
        registrations.find_each(&:push)
      end

      def file_identifier
        self[:file_identifier] || assignable.passbook_file_identifier
      end

      def file_info
        self[:file_info] || assignable.passbook_file_info
      end

      private

      def save_pass_file
        pass_file = Passbook::Pass.new(type_id, serial_number, auth_token, file_identifier, file_info)
        pass_file.save filename
      end

      def delete_file
        FileUtils.rm(path(true), force: true)
      end
    end
  end
end
