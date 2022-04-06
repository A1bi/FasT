# frozen_string_literal: true

module Passbook
  class PassFileCreationError < StandardError; end

  module Models
    class Pass < ApplicationRecord
      attr_readonly :serial_number, :auth_token, :filename

      belongs_to :assignable, polymorphic: true, optional: true
      has_many :registrations, dependent: :destroy
      has_many :devices, through: :registrations

      validates_presence_of :type_id, :serial_number, :auth_token, :filename

      after_initialize :init
      after_commit :delete_file, on: :destroy

      def init
        self.type_id ||= assignable_config[:pass_type_id]
        self.serial_number ||= SecureRandom.hex(10)
        self.auth_token ||= SecureRandom.hex
        self.filename ||= begin
          digest = Digest::SHA1.hexdigest(serial_number + auth_token)
          "pass-#{digest}.pkpass"
        end
      end

      def file_path
        update_file unless File.exist?(file_storage_path)
        file_storage_path
      end

      def file_storage_path
        @file_storage_path ||= File.join(Passbook.destination_path, filename)
      end

      def update_file
        pass_file.save(filename)
        touch
        send_push_notifications
      end

      private

      def pass_file
        @pass_file ||= Passbook::Pass.new(type_id:,
                                          certificate_path:,
                                          serial: serial_number,
                                          auth_token:,
                                          template:,
                                          assets_identifier:,
                                          template_locals: pass_file_info)
      end

      def send_push_notifications
        registrations.find_each(&:push)
      end

      def delete_file
        FileUtils.rm(file_storage_path, force: true)
      end

      def certificate_path
        assignable_config[:certificate_path]
      end

      def template
        assignable_config[:template]
      end

      def assets_identifier
        assignable.passbook_assets_identifier
      end

      def pass_file_info
        assignable.passbook_file_info
      end

      def assignable_config
        @assignable_config ||= begin
          config = Passbook.models[assignable.model_name.i18n_key.to_s] if assignable.present?
          raise 'Missing assignable config' if config.nil?

          config
        end
      end
    end
  end
end
