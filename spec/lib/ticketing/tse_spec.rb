# frozen_string_literal: true

RSpec.describe Ticketing::Tse do
  def parse_payload(payload)
    JSON.parse(payload[1..-2], symbolize_names: true)
  end

  def test_payload
    expect(tls_socket).to receive(:puts) do |params|
      json = parse_payload(params)
      yield json
    end
    subject
  end

  def test_payload_param(name, expected_value)
    test_payload do |json|
      expect(json[name]).to eq(expected_value)
    end
  end

  let(:service) { described_class.new(client_id) }
  let(:command_name) { 'do_something' }
  let(:params) { { foo: 'bar' } }
  let(:client_id) { 'testclient123' }
  let(:responses) { [{ Command: command_name, Status: response_status, PingPong: response_pingpong }] }
  let(:response_status) { 'ok' }
  let(:response_pingpong) { command_id }
  let(:command_id) { '123321' }
  let(:tls_socket) do
    instance_double(OpenSSL::SSL::SSLSocket,
                    'sync_close=': true,
                    connect: true,
                    puts: true)
  end

  before do
    allow(Settings).to receive(:tse).and_return(
      Struct.new(:host, :port).new('tse.example.com', 3456)
    )
    allow(Rails.application.credentials).to receive(:tse).and_return(
      passwords: {
        admin: 'fooadmin',
        time_admin: 'bartime'
      }
    )

    socket = instance_double(TCPSocket)
    allow(TCPSocket).to receive(:new).and_return(socket)
    allow(OpenSSL::SSL::SSLSocket).to receive(:new).with(socket, anything).and_return(tls_socket)

    described_class::CONNECTION_POOL.reload { |_| } # no need to shut down the socket

    allow(tls_socket).to receive(:gets).and_return(
      *responses.map { |res| described_class::STX + res.to_json + described_class::ETX }
    )

    allow(SecureRandom).to receive(:hex).and_return(command_id)
  end

  shared_examples 'common command sending' do
    it 'establishes the connection to the correct host' do
      expect(TCPSocket).to receive(:new).with('tse.example.com', 3456)
      subject
    end

    it 'sends the client id' do
      test_payload_param(:ClientID, client_id)
    end

    context 'when client id is part of the command params' do
      before { params[:ClientID] = 'customID' }

      it 'sends the client id from the params instead of the instance variable' do
        test_payload_param(:ClientID, 'customID')
      end
    end

    it 'sends the command name' do
      test_payload_param(:Command, command_name)
    end

    it 'sends the additional parameters' do
      test_payload do |json|
        expect(json).to include(params)
      end
    end

    context 'when first response does not correspond to this command' do
      let(:response_pingpong) { 'foo' }
      let(:responses) { super() << { Command: command_name, Status: 'ok', PingPong: command_id, Flag: 123 } }

      it 'waits for the corresponding response' do
        expect(subject[:Flag]).to eq(123)
      end
    end

    it 'returns the parsed response' do
      expect(subject).to eq(responses.last)
    end

    context 'when remote responds with an error' do
      let(:response_status) { 'error' }

      it 'raises an error' do
        expect { subject }.to raise_error(described_class::ResponseError)
      end

      it 'fills the error with the original error response' do
        expect { subject }.to raise_error do |error|
          expect(error.response).to include(responses.last)
        end
      end
    end
  end

  describe '#send_command' do
    subject { service.send_command(command_name, params) }

    include_examples 'common command sending'
  end

  describe '#send_admin_command' do
    subject { service.send_admin_command(command_name, params) }

    include_examples 'common command sending'

    it 'sends the base64 encoded admin password as part of the params' do
      test_payload_param(:Password, 'Zm9vYWRtaW4=')
    end
  end

  describe '#send_time_admin_command' do
    subject { service.send_time_admin_command(command_name, params) }

    include_examples 'common command sending'

    it 'sends the base64 encoded time admin password as part of the params' do
      test_payload_param(:Password, 'YmFydGltZQ==')
    end
  end
end
