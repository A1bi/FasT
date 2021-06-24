# frozen_string_literal: true

module Passbook
  module Controllers
    class PassbookController < ApplicationController
      skip_authorization
      ignore_authenticity_token

      before_action :prepare_pass, only: %i[register_device unregister_device
                                            show_pass]
      before_action :prepare_new_device, only: :register_device
      before_action :prepare_device, only: %i[unregister_device modified_passes]

      def register_device
        registration = @device.registrations.where(pass: @pass)
                              .first_or_initialize

        if registration.new_record?
          registration.save
          head :created
        else
          head :ok
        end
      end

      def unregister_device
        @device.passes.delete(@pass) if @device.present?
        head :ok
      end

      def modified_passes
        if @device.nil? || updated_passes.empty?
          head :no_content
        else
          render json: {
            lastUpdated: Time.zone.now.to_i.to_s,
            serialNumbers: updated_passes.pluck(:serial_number)
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
        @pass = Passbook::Models::Pass.find_by(
          type_id: params[:pass_type_id],
          serial_number: params[:serial_number],
          auth_token: auth_token
        )

        head :unauthorized if @pass.nil?
      end

      def prepare_new_device
        @device = Passbook::Models::Device.where(device_id: params[:device_id],
                                                 push_token: params[:pushToken])
                                          .first_or_create
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      def prepare_device
        @device = Passbook::Models::Device.find_by!(params.permit(:device_id))
      end

      def auth_token
        request.headers.fetch('Authorization', '').gsub(/^ApplePass /, '')
      end

      def updated_passes
        @updated_passes ||=
          @device.passes
                 .where('passbook_passes.updated_at > ?', passes_updated_since)
      end

      def passes_updated_since
        Time.zone.at(params[:passesUpdatedSince].to_i || 0)
      end
    end
  end
end
