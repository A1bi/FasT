# frozen_string_literal: true

RSpec.describe Members::MembershipApplicationMailer do
  let(:application) { create(:membership_application, gender:) }
  let(:gender) { :female }
  let(:mailer) { described_class.with(application:) }

  describe '#submitted' do
    subject(:mail) { mailer.submitted }

    it 'is sent to the member' do
      expect(mail.to).to eq([application.email])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Ihr Mitgliedsantrag')
    end

    context 'with a female member' do
      let(:gender) { :female }

      it 'includes a female address' do
        expect(mail.body.encoded).to include("Sehr geehrte Frau #{application.last_name},")
      end
    end

    context 'with a male member' do
      let(:gender) { :male }

      it 'includes a male address' do
        expect(mail.body.encoded).to include("Sehr geehrter Herr #{application.last_name},")
      end
    end

    context 'with a diverse member' do
      let(:gender) { :diverse }

      it 'includes a diverse address' do
        expect(mail.body.encoded).to include("Hallo #{application.name.full},")
      end
    end
  end

  describe '#admin_notification' do
    subject(:mail) { mailer.admin_notification }

    it 'is sent to the configured notification address' do
      expect(mail.to).to eq(['foo@sample.de'])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Neuer Mitgliedsantrag')
    end

    it 'includes the applicant\'s name' do
      expect(mail.body.encoded).to include(application.name.full)
    end
  end
end
