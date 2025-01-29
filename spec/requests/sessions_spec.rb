# frozen_string_literal: true

require_shared_examples 'spam_filtering'

RSpec.describe 'Sessions' do
  describe 'POST #create' do
    subject { post login_path(params) }

    let(:password) { '123456' }
    let(:params) { { email: user.email, password: } }

    shared_examples 'does not show a warning' do
      it 'does not show a warning' do
        subject
        expect(flash[:warning]).to be_nil
      end
    end

    context 'with a regular user' do
      let(:user) { create(:user, password:) }

      include_examples 'does not show a warning'
    end

    context 'with an admin' do
      let(:user) { create(:user, :admin, password:) }

      context 'when WebAuthn credentials exist' do
        before { create(:web_authn_credential, user:) }

        include_examples 'does not show a warning'
      end

      context 'when WebAuthn credentials do not exist' do
        it 'shows a warning' do
          subject
          expect(flash[:warning]).to include('Passkey')
        end
      end
    end
  end
end
