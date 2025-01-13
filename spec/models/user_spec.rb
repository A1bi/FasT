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

  describe '.find_by' do
    subject { described_class.find_by(attrs) }

    let!(:user) { create(:user, email:) }
    let(:email) { 'Abc@example.com' }
    let(:attrs) { { email: } }

    before { create(:user) }

    context 'with matching case' do
      it { is_expected.to eq(user) }
    end

    context 'with non-matching case' do
      let(:email) { 'aBc@example.com' }

      it { is_expected.to eq(user) }
    end

    context 'with non-matching other attributes' do
      let(:attrs) { { email:, first_name: 'foo' } }

      it { is_expected.to be_nil }
    end

    context 'with all matching attributes' do
      let(:attrs) { { email:, first_name: user.first_name } }

      it { is_expected.to eq(user) }
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
