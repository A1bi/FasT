module Passbook
  class PassFileCreationError < StandardError; end

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
        self.filename ||= begin
          digest = Digest::SHA1.hexdigest(serial_number + auth_token)
          "pass-#{digest}.pkpass"
        end
      end

      def file_path
        save_pass_file unless File.exist?(file_storage_path)
        file_storage_path
      end

      def file_storage_path
        @file_storage_path ||= File.join(Passbook.options[:path], filename)
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
        self[:file_identifier] || assignable&.passbook_file_identifier
      end

      def assets_identifier
        self[:assets_identifier] || assignable&.passbook_assets_identifier
      end

      def file_info
        self[:file_info] || assignable&.passbook_file_info
      end

      private

      def save_pass_file
        raise PassFileCreationError unless file_identifier && file_info

        pass_file = Passbook::Pass.new(type_id: type_id,
                                       serial: serial_number,
                                       auth_token: auth_token,
                                       ressources_identifier: file_identifier,
                                       assets_identifier: assets_identifier,
                                       template_locals: file_info)
        pass_file.save filename
      end

      def delete_file
        FileUtils.rm(file_storage_path, force: true)
      end
    end
  end
end
