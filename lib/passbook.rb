require "zip/zip"

module Passbook
  
  def self.options
    @options ||= {}
  end
  
  class Pass < AbstractController::Base
    include AbstractController::Rendering
    include AbstractController::Translation
    
    append_view_path "app/views"
    
    def initialize(identifier, info)
      @identifier = identifier
      @info = JSON(render_to_string(template: "passbook/#{@identifier}", format: :json, locals: { info: info }))
    end
    
    def create(path)
      create_working_dir
      create_pass_info(@info)
      copy_images
      create_manifest
      sign
      zip(path)
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
end
