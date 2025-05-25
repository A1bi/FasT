# frozen_string_literal: true

require 'support/authentication'

RSpec.describe 'Members::DashboardController' do
  describe 'GET #index' do
    subject { get members_root_path }

    before { sign_in(admin: true, web_authn:) }

    context 'when WebAuthn is set up for an admin' do
      let(:web_authn) { true }

      it 'does not show a warning' do
        subject
        expect(flash[:warning]).to be_nil
      end
    end

    context 'when WebAuthn is not set up for an admin' do
      let(:web_authn) { false }

      it 'shows a warning' do
        subject
        expect(flash[:warning]).to include('Passkey')
      end
    end
  end
end
