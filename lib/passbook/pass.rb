# frozen_string_literal: true

require 'zip'

module Passbook
  class Pass < AbstractController::Base
    include AbstractController::Rendering
    include AbstractController::Translation
    include ActionView::Layouts
    include AbstractController::Helpers
    include Rails.application.routes.url_helpers

    IMAGES_BASE_PATH = Rails.root.join('app/assets/passbook')

    append_view_path ApplicationController.view_paths

    def initialize(type_id:, team_id:, certificate_path:, serial:, auth_token:, template:,
                   assets_identifier:, template_locals:)
      super()
      @type_id = type_id
      @team_id = team_id
      @certificate_path = certificate_path
      @serial = serial
      @auth_token = auth_token
      @template = template
      @assets_identifier = assets_identifier
      @template_locals = template_locals
    end

    def save(filename)
      path = Passbook.destination_path
      FileUtils.mkdir_p(path)
      path = File.join(path, filename)

      create_working_dir
      create_pass_info
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

    def create_pass_info
      info = render_to_string(template: "passbook/#{@template}", locals: @template_locals)
      write_json_file(info, 'pass.json')
    end

    def copy_images
      ['_common', @assets_identifier].each do |directory|
        iterate_dir(IMAGES_BASE_PATH.join(directory)) do |file|
          FileUtils.cp file, path_in_working_dir(File.basename(file))
        end
      end
    end

    def create_manifest
      manifest = {}
      working_dir = Pathname.new(@working_dir)

      iterate_working_dir do |file|
        path = Pathname.new(file).relative_path_from(working_dir)
        manifest[path] = Digest::SHA1.hexdigest(File.read(file))
      end

      write_json_file(manifest, 'manifest.json')
    end

    def sign
      p12 = OpenSSL::PKCS12.new(File.read(@certificate_path))
      wwdr = OpenSSL::X509::Certificate.new(File.read(Passbook.wwdr_ca_path))
      manifest = File.read(path_in_working_dir('manifest.json'))

      signature = OpenSSL::PKCS7.sign(
        p12.certificate, p12.key, manifest, [wwdr],
        OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::DETACHED
      )

      File.write(path_in_working_dir('signature'), signature.to_der.force_encoding('utf-8'))
    end

    def zip(path)
      FileUtils.rm_f(path)
      Zip::File.open(path, Zip::File::CREATE) do |zip_file|
        iterate_working_dir do |file|
          zip_file.add(File.basename(file), file)
        end
      end

      FileUtils.chmod('a+r', path)
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

    def write_json_file(content, file)
      File.write(path_in_working_dir(file), content.is_a?(Hash) ? content.to_json : content)
    end
  end
end
