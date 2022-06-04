# frozen_string_literal: true

module Ticketing
  class Tse
    class Error < StandardError; end
    class NotConnectedError < Error; end
    class TseDisabledError < Error; end

    class ResponseError < Error
      attr_reader :response

      def initialize(response)
        super
        @response = response
      end
    end

    STX = [2].pack('C')
    ETX = [3].pack('C')

    class << self
      def connect(client_id)
        tse = new(client_id)
        tse.connect
        yield tse
        tse.disconnect
      end
    end

    def initialize(client_id)
      @client_id = client_id
    end

    def send_admin_command(command, params = {})
      params[:Password] = password_for(:admin)
      send_command(command, params)
    end

    def send_time_admin_command(command, params = {})
      params[:Password] = password_for(:time_admin)
      send_command(command, params)
    end

    def send_command(command, params = {})
      command_id = SecureRandom.hex

      payload = {
        Command: command,
        PingPong: command_id,
        **params
      }
      payload[:ClientID] = @client_id unless params.key?(:ClientID)

      socket.puts STX + payload.to_json + ETX

      loop do
        data = socket.gets
        json = data[(data.index(STX) + 1)...data.index(ETX)] # faster than regex
        response = JSON.parse(json, symbolize_names: true)
        next unless response[:PingPong] == command_id

        raise(ResponseError, response) unless response[:Status] == 'ok'

        break response
      end
    end

    def connect
      raise TseDisabledError unless Settings.tse.enabled

      tcp_socket = TCPSocket.new Settings.tse.host, Settings.tse.port

      ctx = OpenSSL::SSL::SSLContext.new
      ctx.set_params(verify_mode: OpenSSL::SSL::VERIFY_PEER)

      @socket = OpenSSL::SSL::SSLSocket.new(tcp_socket, ctx)
      @socket.sync_close = true
      @socket.connect
    end

    def disconnect
      socket.close
      @socket = nil
    end

    def socket
      raise NotConnectedError if @socket.nil?

      @socket
    end

    def password_for(role)
      Base64.strict_encode64(Rails.application.credentials.tse[:passwords][role])
    end
  end
end
