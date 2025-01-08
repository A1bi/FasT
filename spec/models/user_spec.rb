# frozen_string_literal: true

RSpec.describe User do
  describe 'initial password' do
    subject { user.save }

    let(:user) { build(:user, password:) }

    context 'when no password is set before' do
      let(:password) { nil }

      it 'sets a random password' do
        expect { subject }.to change(user, :password).from(password)
      end
    end

    context 'when a password is set before' do
      let(:password) { 'fooby' }

      it 'sets a random password' do
        expect { subject }.not_to change(user, :password).from(password)
      end
    end
  end

  describe '#web_authn_required?' do
    subject { user.web_authn_required? }

    let(:user) { create(:user) }

    context 'without any WebAuthn credentials present' do
      it { is_expected.to be_falsy }
    end

    context 'with some WebAuthn credentials present' do
      before { create(:web_authn_credential, user:) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#reset_activation!' do
    subject { user.reset_activation! }

    let(:user) { create(:user) }

    before { create(:web_authn_credential, user:) }

    it 'resets the password' do
      expect { subject }.to change(user, :password)
    end

    it 'removes all passkeys' do
      expect { subject }.to change(user.web_authn_credentials, :count).to(0)
    end
  end
end
