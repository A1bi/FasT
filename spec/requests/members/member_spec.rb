# frozen_string_literal: true

RSpec.describe 'Members::Member' do
  describe 'POST #finish_forgot_password' do
    subject { post finish_forgot_password_members_member_path(params) }

    let(:params) { { members_member: { email: } } }
    let(:member) { create(:member) }
    let(:email) { member.email }

    shared_examples 'successful message' do
      it 'shows successful message' do
        subject
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to include('zugeschickt')
      end
    end

    context 'with a known email address' do
      include_examples 'successful message'

      it 'sends an email with instructions' do
        expect { subject }.to have_enqueued_mail(Members::MemberMailer, :reset_password)
          .with(a_hash_including(params: { member: }))
      end
    end

    context 'with an unknown email address' do
      let(:email) { 'foo@bar.com' }

      include_examples 'successful message'

      it 'does not send an email with instructions' do
        expect { subject }.not_to have_enqueued_mail(Members::MemberMailer)
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
