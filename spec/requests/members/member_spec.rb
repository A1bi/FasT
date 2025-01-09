# frozen_string_literal: true

RSpec.describe 'Members::Member' do
  describe 'POST #finish_forgot_password' do
    subject { post finish_forgot_password_members_member_path(params) }

    let(:params) { { members_member: { email: } } }
    let(:member) { create(:member) }
    let(:email) { member.email }

    context 'with a known email address' do
      it 'shows successful message' do
        subject
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to include('zugeschickt')
      end

      it 'sends an email with instructions' do
        expect { subject }.to have_enqueued_mail(Members::MemberMailer, :reset_password)
          .with(a_hash_including(params: { member: }))
      end
    end

    context 'with an unknown email address' do
      let(:email) { 'foo@bar.com' }

      it 'shows error' do
        subject
        expect(flash[:alert]).to include('nicht gefunden')
      end
    end

    context 'with an email address for a user with WebAuthn required' do
      before { create(:web_authn_credential, user: member) }

      it 'shows error' do
        subject
        expect(flash[:alert]).to include('Passkey zurückzusetzen')
      end
    end
  end
end
