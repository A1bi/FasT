module Passbook
  module Controllers
    class PassbookController < ApplicationController
      ignore_authenticity_token

      before_action :prepare_pass, only: [:register_device, :unregister_device, :show_pass]
      before_action :prepare_device, only: [:unregister_device, :modified_passes]

      def register_device
        begin
          device = Passbook::Models::Device.where(device_id: params[:device_id], push_token: params[:pushToken]).first_or_create
        rescue ActiveRecord::RecordNotUnique
          retry
        end

        registration = device.registrations.where(pass: @pass).first_or_initialize

        if registration.new_record?
          registration.save
          head 201
        else
          head :ok
        end
      end

      def unregister_device
        @device.passes.delete(@pass) if @device.present?
        head :ok
      end

      def modified_passes
        if @device.present?
          passes = @device.passes.where("passbook_passes.updated_at > ?", Time.at((params[:passesUpdatedSince] || 0).to_i))
        end

        if @device.nil? || passes.empty?
          head 204
        else
          render json: {
            lastUpdated: Time.zone.now.to_i.to_s,
            serialNumbers: passes.map { |pass| pass.serial_number }
          }
        end
      end

      def show_pass
        send_file @pass.file_path if stale? @pass
      rescue Passbook::PassFileCreationError
        head :not_found
      end

      def log
        (params[:logs] ||= []).each do |message|
          Passbook::Models::Log.create(message: message)
        end

        head :ok
      end

      private

      def prepare_pass
        auth_token = request.headers.fetch('Authorization', '').gsub(/^ApplePass /, '')
        @pass = Passbook::Models::Pass.find_by(type_id: params[:pass_type_id], serial_number: params[:serial_number])

        head 401 if @pass.nil? || @pass.auth_token != auth_token
      end

      def prepare_device
        @device = Passbook::Models::Device.where(device_id: params[:device_id]).first
      end
    end
  end
end
