# frozen_string_literal: true

RSpec.describe Ticketing::OrderMailer do
  let(:mailer) { described_class.with(params) }
  let(:params) { { order: } }
  let(:order) { create(:web_order, :with_purchased_coupons) }

  shared_examples 'basic email properties' do |subject|
    context 'with a web order' do
      it 'renders the headers' do
        expect(mail.subject).to eq(subject)
        expect(mail.to).to eq([order.email])
        expect(mail.from.count).to eq(1)
        expect(mail.from.first).to eq('noreply@theater-kaisersesch.de')
        expect(mail.reply_to.first).to eq('info@theater-kaisersesch.de')
      end
    end

    context 'without a web order' do
      let(:order) { create(:retail_order, :with_purchased_coupons) }

      it 'does not process the email' do
        expect(order).not_to receive(:email)
        expect(mail.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#confirmation' do
    subject(:mail) { mailer.confirmation }

    it_behaves_like 'basic email properties', 'Ihre Bestellung'
  end
end
