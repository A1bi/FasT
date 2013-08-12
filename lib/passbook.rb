require "zip/zip"

module Passbook
  
  def self.options
    @options ||= {}
  end
  
  class Pass < AbstractController::Base
    include AbstractController::Rendering
    include AbstractController::Translation
    
    append_view_path "app/views"
    
    def initialize(identifier, info, assignable = nil)
      @identifier = identifier
      @info = JSON(render_to_string(template: "passbook/#{@identifier}", format: :json, locals: { info: info }), symbolize_names: true)
      
      if assignable
        @record = assignable.passbook_pass
        if !@record
          @record = Records::Pass.new(type_id: @info[:passTypeIdentifier], serial_number: @info[:serialNumber])
          @record.assignable = assignable
          @record.auth_token = SecureRandom.hex
          @record.filename = "pass-#{Digest::SHA1.hexdigest(@info[:serialNumber].to_s)}#{SecureRandom.hex(4)}.pkpass"
        end
        @info[:authenticationToken] = @record.auth_token
      end
    end
    
    def create(filename = nil)
      path = Passbook.options[:full_path]
      FileUtils.mkdir_p(path)
      path = File.join(path, @record.filename || filename)
      
      create_working_dir
      create_pass_info(@info)
      copy_images
      create_manifest
      sign
      zip(path)
      
      if @record
        @record.touch if !@record.new_record?
        @record.save
      end
    end
    
    private
    
    def create_working_dir
      @working_dir = File.join(Dir.tmpdir, "passbook.#{SecureRandom.hex}")
      FileUtils.mkdir_p @working_dir
    end
    
    def create_pass_info(info)
      write_json_file(@info, "pass.json")
    end
    
    def copy_images
      iterate_dir(File.join(Rails.root, "app", "assets", "images", "passbook", @identifier)) do |file|
        FileUtils.cp file, path_in_working_dir(File.basename(file))
      end
    end
    
    def create_manifest
      manifest = {}
      working_dir = Pathname.new(@working_dir)
      
      iterate_working_dir do |file|
        path = Pathname.new(file).relative_path_from(working_dir)
        manifest[path] = Digest::SHA1.hexdigest(File.read(file));
      end
      
      write_json_file(manifest, "manifest.json")
    end
    
    def sign
      p12 = OpenSSL::PKCS12.new File.read(Passbook.options[:developer_cert_path])
      wwdr  = OpenSSL::X509::Certificate.new File.read(Passbook.options[:wwdr_ca_path])
      
      signature = OpenSSL::PKCS7.sign(p12.certificate, p12.key, File.read(path_in_working_dir("manifest.json")), [wwdr], OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED)
      
      File.open(path_in_working_dir("signature"), "wb") do |file|
        file.write(signature.to_der)
      end
    end
    
    def zip(path)
      FileUtils.rm(path) if File.exists?(path)
      Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zip_file|
        iterate_working_dir do |file|
          zip_file.add(File.basename(file), file)
        end
      end
      
      FileUtils.chmod("a+r", path)
      FileUtils.rm_r(@working_dir)
    end
    
    def iterate_dir(path, &block)
      Dir[File.join(path, '**', '**')].each do |file|
        block.call(file)
      end
    end
    
    def iterate_working_dir(&block)
      iterate_dir(@working_dir) { |file| block.call(file) }
    end
    
    def path_in_working_dir(file)
      File.join(@working_dir, file)
    end
    
    def write_json_file(hash, file)
      File.open(path_in_working_dir(file), "w") do |file|
        file.write(hash.to_json)
      end
    end
  end
  
  
  module Records
    
    def self.table_name_prefix
      'passbook_'
    end

    class Pass < ActiveRecord::Base
      attr_accessible :type_id, :serial_number
      
      belongs_to :assignable, :polymorphic => true
      has_many :registrations, :dependent => :destroy
      has_many :devices, through: :registrations

      validates_presence_of :type_id, :serial_number, :auth_token
      
      after_destroy :delete_file
      
      def path(full = false)
        File.join(Passbook.options[full ? :full_path : :path], filename)
      end
      
      private
      
      def delete_file
        FileUtils.rm(path(true))
      end
    end

    class Device < ActiveRecord::Base
      attr_accessible :device_id, :push_token, :push_token
      
      has_many :registrations, :dependent => :destroy
      has_many :passes, through: :registrations

      validates_presence_of :device_id, :push_token
    end
    
    class Registration < ActiveRecord::Base
      attr_accessible :device, :pass
      
      belongs_to :device
      belongs_to :pass
      
      validates_presence_of :device, :pass
    end

    class Log < ActiveRecord::Base
      attr_accessible :message
      
      validates_presence_of :message
    end
    
  end
  
  
  module Controllers
    
    class PassbookController < ApplicationController
      before_filter :prepare_pass, only: [:register_device, :unregister_device, :show_pass]
      before_filter :prepare_device, only: [:unregister_device, :modified_passes]
      
      def register_device
        device = Passbook::Records::Device.where(device_id: params[:device_id], push_token: params[:pushToken]).first_or_create
        registration = Passbook::Records::Registration.where(pass_id: @pass.id, device_id: device.id).first_or_initialize
        
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
        
        if passes.count < 1
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
          Passbook::Records::Log.create(message: message)
        end
        
        render nothing: true
      end
      
      private
      
      def prepare_pass
        auth_token = request.headers['Authorization'].gsub(/^ApplePass /, "")
        
        @pass = Passbook::Records::Pass.where(type_id: params[:pass_type_id], serial_number: params[:serial_number]).first
        
        if @pass.nil? || @pass.auth_token != auth_token
          return render nothing: true, status: 401
        end
      end
      
      def prepare_device
        @device = Passbook::Records::Device.where(device_id: params[:device_id]).first
      end
    end
    
  end
  
end
