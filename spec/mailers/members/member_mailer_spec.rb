# frozen_string_literal: true

RSpec.describe Members::MemberMailer do
  let(:member) { create(:member, gender:, email:) }
  let(:gender) { :female }
  let(:mailer) { described_class.with(member:) }
  let(:email) { 'foo@bar.com' }

  shared_examples 'an email addressed to a member' do
    context 'when member has own email address' do
      it 'is sent to the member' do
        expect(mail.to).to eq([member.email])
      end
    end

    it 'has the correct subject' do
      expect(mail.subject).to include(subject)
    end

    context 'with a female member' do
      let(:gender) { :female }

      it 'includes a female address' do
        expect(mail.body.encoded).to include("Sehr geehrte Frau #{member.last_name},")
      end
    end

    context 'with a male member' do
      let(:gender) { :male }

      it 'includes a male address' do
        expect(mail.body.encoded).to include("Sehr geehrter Herr #{member.last_name},")
      end
    end

    context 'with a diverse member' do
      let(:gender) { :diverse }

      it 'includes a diverse address' do
        expect(mail.body.encoded).to include("Hallo #{member.name.full},")
      end
    end
  end

  shared_examples 'an email addressed to a member without email address' do
    context 'when member lacks email address' do
      let(:email) { nil }

      it 'is sent to no one' do
        expect(mail.to).to be_nil
      end
    end
  end

  describe '#welcome' do
    subject(:mail) { mailer.welcome }

    let(:member) { create(:member, :with_sepa_mandate, gender:, email:, membership_fee: 13.4) }
    let(:subject) { 'Herzlich willkommen' } # rubocop:disable RSpec/SubjectDeclaration

    it_behaves_like 'an email addressed to a member'

    it 'contains info about the SEPA mandate' do
      expect(mail.body.encoded)
        .to include(
          *member.sepa_mandate.attributes.slice(:debtor_name, :iban),
          member.sepa_mandate.number(prefixed: true),
          '13,40 €'
        )
    end

    it 'does not mention a membership application' do
      expect(mail.body.encoded).not_to include('antrag')
    end

    it 'mentions a following member account activation email' do
      expect(mail.body.encoded).to include('Mitgliedskonto')
    end

    context 'when a membership application is associated with the member' do
      before { create(:membership_application, member:) }

      it 'mentions a membership application' do
        expect(mail.body.encoded).to include('antrag')
      end
    end

    context 'when only another family member has an email address' do
      let(:email) { nil }
      let(:family_members) { create_list(:member, 2) }

      before do
        family_members.each do |m|
          m.add_to_family_with_member(member)
          m.save
        end
        family_members.last.update(email: nil)
      end

      it 'is sent to the family member' do
        expect(mail.to).to eq([family_members.first.email])
      end

      it 'does not mention a following member account activation email' do
        expect(mail.body.encoded).not_to include('Mitgliedskonto')
      end
    end
  end

  describe '#activation' do
    subject(:mail) { mailer.activation }

    let(:subject) { 'Aktivierung' } # rubocop:disable RSpec/SubjectDeclaration

    before do
      allow(member).to receive(:generate_token_for).with(:activation).and_return('footoken')
    end

    it_behaves_like 'an email addressed to a member'
    it_behaves_like 'an email addressed to a member without email address'

    it 'contains a link to activate the account' do
      expect(mail.body.encoded).to match(%r{https?://.+token=footoken})
    end
  end

  describe '#reset_password' do
    subject(:mail) { mailer.reset_password }

    let(:subject) { 'Passwort zurücksetzen' } # rubocop:disable RSpec/SubjectDeclaration

    before do
      allow(member).to receive(:generate_token_for).with(:password_reset).and_return('tokenfoo')
    end

    it_behaves_like 'an email addressed to a member'
    it_behaves_like 'an email addressed to a member without email address'

    it 'contains a link to reset the password' do
      expect(mail.body.encoded).to match(%r{https?://.+token=tokenfoo})
    end
  end
end
