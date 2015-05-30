module Passbook
  module Controllers
    class PassbookController < ApplicationController
      before_filter :prepare_pass, only: [:register_device, :unregister_device, :show_pass]
      before_filter :prepare_device, only: [:unregister_device, :modified_passes]
    
      def register_device
        begin
          device = Passbook::Models::Device.where(device_id: params[:device_id], push_token: params[:pushToken]).first_or_create
        rescue ActiveRecord::RecordNotUnique
          retry
        end
        
        registration = device.registrations.where(pass: @pass).first_or_initialize
        
        if registration.new_record?
          registration.save
          render nothing: true, status: 201
        else
          render nothing: true
        end
      end
    
      def unregister_device
        return render nothing: true if @device.nil?
      
        @device.passes.delete(@pass)
      
        render nothing: true
      end
    
      def modified_passes
        return render nothing: true, status: 204 if @device.nil?
      
        params[:passesUpdatedSince] ||= 0
      
        passes = @device.passes.where("passbook_passes.updated_at > ?", Time.at(params[:passesUpdatedSince].to_i))
      
        if passes.empty?
          render nothing: true, status: 204
        else
          render json: {
            lastUpdated: Time.zone.now.to_i.to_s,
            serialNumbers: passes.map { |pass| pass.serial_number }
          }
        end
      end
    
      def show_pass
        send_file @pass.path(true) if stale? @pass
      end
    
      def log
        (params[:logs] ||= []).each do |message|
          Passbook::Models::Log.create(message: message)
        end
      
        render nothing: true
      end
    
      private
    
      def prepare_pass
        auth_token = request.headers['Authorization'].gsub(/^ApplePass /, "")
      
        @pass = Passbook::Models::Pass.where(type_id: params[:pass_type_id], serial_number: params[:serial_number]).first
      
        if @pass.nil? || @pass.auth_token != auth_token
          return render nothing: true, status: 401
        end
      end
    
      def prepare_device
        @device = Passbook::Models::Device.where(device_id: params[:device_id]).first
      end
    end
  end
end