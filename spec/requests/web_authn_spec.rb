# frozen_string_literal: true

require 'webauthn/fake_client'
require 'webmock/rspec'
require 'support/authentication'

RSpec.describe 'WebAuthn' do
  let(:params) { nil }
  let(:user) { create(:user) }
  let!(:existing_credential) { create(:web_authn_credential, user:) }
  let(:fake_client) { WebAuthn::FakeClient.new(WebAuthn.configuration.origin) }

  before do
    stub_request(:get, 'https://github.com/passkeydeveloper/passkey-authenticator-aaguids/raw/refs/heads/main/combined_aaguid.json')
      .to_return(body: '{}')
  end

  shared_examples 'user login' do
    let(:user) { create(:member, :with_sepa_mandate) }

    it 'logs the user in' do
      subject
      get edit_members_member_path
      expect(response.body).to include(user.name.full)
    end
  end

  describe 'GET #options_for_create' do
    subject { get web_authn_options_for_create_path(params) }

    let(:web_authn_id) { 'foo_id' }
    let(:expected_response) do
      {
        rp: { name: 'TheaterKultur Kaisersesch' },
        user: { id: web_authn_id, name: user.email, displayName: user.name.full },
        excludeCredentials: [{ id: existing_credential.id, type: 'public-key' }],
        authenticatorSelection: {
          residentKey: 'required',
          userVerification: 'required'
        },
        attestation: 'indirect'
      }
    end

    before { allow(WebAuthn).to receive(:generate_user_id).and_return(web_authn_id) }

    context 'without authenticated user' do
      it 'redirects to root' do
        subject
        expect(response).to redirect_to(login_path)
      end
    end

    shared_examples 'returns valid options' do
      it 'returns valid options' do
        subject
        expect(response.parsed_body).to include(expected_response.deep_stringify_keys)
        expect(response.parsed_body.keys).to include('challenge', 'pubKeyCredParams')
      end

      it "sets the user's WebAuthn id" do
        expect { subject }.to change { user.reload.webauthn_id }.from(nil).to(web_authn_id)
      end
    end

    context 'with authenticated user' do
      before { sign_in(user:) }

      include_examples 'returns valid options'
    end

    context 'with activation token' do
      let(:params) { { activation_token: user.generate_token_for(:activation) } }

      include_examples 'returns valid options'
    end
  end

  describe 'POST #create' do
    subject { post web_authn_create_path(**params, credential: challenge_response) }

    let(:params) { { activation_token: user.generate_token_for(:activation) } }
    let(:challenge) do
      get web_authn_options_for_create_path(params)
      response.parsed_body['challenge']
    end
    let(:challenge_response) { fake_client.create(challenge:) }

    shared_examples 'creates a credential' do
      it 'creates a credential' do
        expect { subject }.to change(user.web_authn_credentials, :count).by(1)
      end
    end

    context 'with a valid challenge response' do
      it 'returns goto path' do
        subject
        expect(response.parsed_body).to eq('goto_path' => members_root_path)
        expect(flash[:notice]).to include('erfolgreich aktiviert')
      end

      include_examples 'creates a credential'
      include_examples 'user login'
    end

    context 'with an invalid challenge response' do
      let(:challenge) { 'foo' }

      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
        expect(flash[:alert]).to include('nicht registriert')
      end

      it 'does not create a credential' do
        expect { subject }.not_to change(WebAuthnCredential, :count)
      end
    end

    context 'with an authenticated user' do
      let(:params) { {} }

      before { sign_in(user:) }

      it 'returns successful response' do
        subject
        expect(response).to have_http_status(:created)
        expect(flash[:notice]).to include('wurde hinzugefügt')
      end

      include_examples 'creates a credential'
    end
  end

  describe 'GET #options_for_auth' do
    subject { get web_authn_options_for_auth_path }

    let(:expected_response) do
      {
        allowCredentials: [],
        userVerification: 'required'
      }
    end

    it 'returns valid options' do
      subject
      expect(response.parsed_body).to include(expected_response.deep_stringify_keys)
      expect(response.parsed_body.keys).to include('challenge')
    end
  end

  describe 'POST #auth' do
    subject { post web_authn_auth_path(params) }

    let(:params) { { credential: challenge_response } }
    let(:challenge) do
      get web_authn_options_for_auth_path
      response.parsed_body['challenge']
    end
    let(:challenge_response) { fake_client.get(challenge:) }

    before do
      create_params = { activation_token: user.generate_token_for(:activation) }
      get web_authn_options_for_create_path(create_params)
      challenge = response.parsed_body['challenge']
      challenge_response = fake_client.create(challenge:)
      post web_authn_create_path(**create_params, credential: challenge_response)
      get root_path, headers: { cookie: nil }
    end

    context 'with a valid challenge response' do
      it 'returns goto path' do
        subject
        expect(response.parsed_body).to eq('goto_path' => members_root_path)
      end

      include_examples 'user login'
    end

    context 'with an invalid challenge response' do
      let(:challenge) { 'foo' }

      it 'returns bad request' do
        subject
        expect(response).to have_http_status(:bad_request)
        expect(flash[:alert]).to include('ungültig')
      end
    end

    context 'with valid challenge response but missing user' do
      it 'returns bad request' do
        user.destroy
        subject
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
