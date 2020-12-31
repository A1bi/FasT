# frozen_string_literal: true

RSpec.describe Members::MemberMailer do
  let(:member) { create(:member, gender: gender) }
  let(:gender) { :female }
  let(:mailer) { described_class.with(member: member) }

  shared_examples 'an email addressed to a member' do
    it 'is sent to the member' do
      expect(mail.to).to eq([member.email])
    end

    it 'has the correct subject' do
      expect(mail.subject).to include(subject)
    end

    context 'with a female member' do
      let(:gender) { :female }

      it 'includes a female address' do
        expect(mail.body.encoded)
          .to include("Sehr geehrte Frau #{member.last_name},")
      end
    end

    context 'with a male member' do
      let(:gender) { :male }

      it 'includes a male address' do
        expect(mail.body.encoded)
          .to include("Sehr geehrter Herr #{member.last_name},")
      end
    end

    context 'with a diverse member' do
      let(:gender) { :diverse }

      it 'includes a diverse address' do
        expect(mail.body.encoded)
          .to include("Hallo #{member.name.full},")
      end
    end
  end

  shared_examples 'activation link' do
    it 'contains a link to activate the account' do
      member.set_activation_code
      expect(mail.body.encoded)
        .to match(%r{https?://.+code=#{member.activation_code}})
    end
  end

  describe '#welcome' do
    subject(:mail) { mailer.welcome }

    let(:member) do
      create(:member, :with_sepa_mandate, gender: gender, membership_fee: 13.4)
    end
    let(:subject) { 'Willkommen' }

    it_behaves_like 'an email addressed to a member'

    it 'contains info about the SEPA mandate' do
      expect(mail.body.encoded)
        .to include(
          *member.sepa_mandate.attributes.slice(:debtor_name, :iban),
          member.sepa_mandate.number(prefixed: true),
          '13,40 €'
        )
    end
  end

  describe '#activation' do
    subject(:mail) { mailer.activation }

    let(:subject) { 'Aktivierung' }

    it_behaves_like 'an email addressed to a member'
    include_examples 'activation link'
  end

  describe '#reset_password' do
    subject(:mail) { mailer.reset_password }

    let(:subject) { 'Passwort zurücksetzen' }

    it_behaves_like 'an email addressed to a member'
    include_examples 'activation link'
  end
end
