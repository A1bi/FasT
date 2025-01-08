# frozen_string_literal: true

RSpec.describe User do
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
end
