module Api
  class MobileDevicesController < ApiController
    PROFILE_CONTENT_TYPE = 'application/x-apple-aspen-config'.freeze

    def profile
      send_data signed_profile_data, content_type: PROFILE_CONTENT_TYPE
    end

    def enroll
      device = MobileDevice.where(udid: device_attributes['UDID'])
                           .first_or_initialize

      device.update(identifier: device_identifier,
                    product: device_attributes['PRODUCT'],
                    version: device_attributes['VERSION'])

      head :unauthorized
    end

    private

    def signed_profile_data
      cert = OpenSSL::PKCS12.new(File.read(certificate_path))
      wwdr = OpenSSL::X509::Certificate.new(File.read(wwdr_ca_path))
      OpenSSL::PKCS7.sign(cert.certificate, cert.key, profile_data, [wwdr],
                          OpenSSL::PKCS7::BINARY)
                    .to_der
    end

    def profile_data
      render_to_string :profile, layout: false, formats: :plist
    end

    def device_identifier
      return if params[:id].blank?

      Base64.urlsafe_decode64(params[:id])
    end

    def device_attributes
      @device_attributes ||= begin
        p7sign = OpenSSL::PKCS7.new(request.body.read)
        store = OpenSSL::X509::Store.new
        p7sign.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)
        Plist.parse_xml(p7sign.data)
      end
    end

    def config
      Settings.mobile_devices
    end

    delegate :certificate_path, :wwdr_ca_path, to: :config
  end
end
