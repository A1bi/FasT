# frozen_string_literal: true

RSpec.describe Members::MemberMailer do
  let(:member) { create(:member, gender: gender) }
  let(:gender) { :female }

  shared_examples 'an email addressed to a member' do
    it 'is sent to the member' do
      expect(mail.to).to eq([member.email])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq(subject)
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

  describe '#welcome' do
    subject(:mail) { described_class.with(member: member).welcome }

    let(:member) do
      create(:member, :with_sepa_mandate, gender: gender, membership_fee: 13.4)
    end
    let(:subject) { 'Willkommen in unserem Verein' }

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
end
