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

  def expect_payload_param(name, expected_value)
    test_payload do |json|
      expect(json[name]).to eq(expected_value)
    end
  end

  let(:service) { described_class.new(client_id) }
  let(:client_id) { 'testclient123' }
  let(:tls_socket) do
    instance_double(OpenSSL::SSL::SSLSocket,
                    'sync_close=': true,
                    connect: true,
                    puts: true,
                    close: true)
  end

  before do
    allow(Settings).to receive(:tse).and_return(
      Struct.new(:enabled, :host, :port).new(true, 'tse.example.com', 3456)
    )

    socket = instance_double(TCPSocket)
    allow(TCPSocket).to receive(:new).and_return(socket)
    allow(OpenSSL::SSL::SSLSocket).to receive(:new).with(socket, anything).and_return(tls_socket)
  end

  describe '.connect' do
    subject do
      described_class.connect(client_id) { |t| t.send_command(:hello, foo: :bar) }
    end

    let(:tse) { instance_double(described_class, connect: true, disconnect: true) }

    before do
      allow(described_class).to receive(:new).and_return(tse)
      allow(tse).to receive(:send_command)
    end

    it 'creates a new TSE instance with the provided client_id' do
      expect(described_class).to receive(:new).with(client_id)
      subject
    end

    it 'calls the methods in the right order' do
      expect(tse).to receive(:connect).ordered
      expect(tse).to receive(:send_command).with(:hello, foo: :bar).ordered
      expect(tse).to receive(:disconnect).ordered
      subject
    end
  end

  describe '#connect' do
    subject { service.connect }

    it 'establishes the connection to the correct host' do
      expect(TCPSocket).to receive(:new).with('tse.example.com', 3456)
      subject
    end
  end

  describe '#disconnect' do
    subject { service.disconnect }

    before { service.connect }

    it 'establishes the connection to the correct host' do
      expect(tls_socket).to receive(:close)
      subject
    end
  end

  describe 'sending methods' do
    let(:command_name) { 'do_something' }
    let(:params) { { foo: 'bar' } }
    let(:responses) { [{ Command: command_name, Status: response_status, PingPong: response_pingpong }] }
    let(:response_status) { 'ok' }
    let(:response_pingpong) { command_id }
    let(:command_id) { '123321' }
    let(:skip_connect) { false }

    before do
      allow(Rails.application.credentials).to receive(:tse).and_return(
        passwords: {
          admin: 'fooadmin',
          time_admin: 'bartime'
        }
      )

      allow(tls_socket).to receive(:gets).and_return(
        *responses.map { |res| "#{described_class::STX}#{res.to_json}#{described_class::ETX} " }
      )

      allow(SecureRandom).to receive(:hex).and_return(command_id)

      service.connect unless skip_connect
    end

    shared_examples 'common command sending' do
      it 'sends the client id' do
        expect_payload_param(:ClientID, client_id)
      end

      context 'when client id is part of the command params' do
        before { params[:ClientID] = 'customID' }

        it 'sends the client id from the params instead of the instance variable' do
          expect_payload_param(:ClientID, 'customID')
        end
      end

      it 'sends the command name' do
        expect_payload_param(:Command, command_name)
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

      context 'when instance has not been connected yet' do
        let(:skip_connect) { true }

        it 'raises an error' do
          expect { subject }.to raise_error(described_class::NotConnectedError)
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
        expect_payload_param(:Password, 'Zm9vYWRtaW4=')
      end
    end

    describe '#send_time_admin_command' do
      subject { service.send_time_admin_command(command_name, params) }

      include_examples 'common command sending'

      it 'sends the base64 encoded time admin password as part of the params' do
        expect_payload_param(:Password, 'YmFydGltZQ==')
      end
    end
  end
end
