# frozen_string_literal: true

RSpec.describe Ticketing::Covid19CheckInMailer do
  describe '#check_in' do
    subject(:mail) { described_class.check_in(ticket) }

    let(:ticket) { order.tickets[0] }
    let(:event) { create(:event, :complete, covid19_presence_tracing: true) }

    context 'with a web order' do
      let(:order) { create(:web_order, :with_tickets, event: event) }
      let(:check_in_url) { 'https://foobar.com' }

      before do
        allow(ticket.date).to receive(:covid19_check_in_url).and_return(check_in_url)
      end

      it 'renders the headers' do
        expect(mail.subject).to eq('Herzlich willkommen')
        expect(mail.to).to eq([order.email])
        expect(mail.from.count).to eq(1)
        expect(mail.from.first).to eq('noreply@theater-kaisersesch.de')
        expect(mail.reply_to.first).to eq('info@theater-kaisersesch.de')
      end

      it 'includes the COVID-19 check-in URL' do
        expect(mail.text_part.body).to include(check_in_url)
        expect(mail.html_part.body).to include(check_in_url)
      end
    end

    context 'without a web order' do
      let(:order) { create(:retail_order, :with_tickets, event: event) }

      before do
        stub_const('Ticketing::TicketsRetailPdf', double.as_null_object)
      end

      it 'does not process the email' do
        expect(order).not_to receive(:email)
        expect(mail.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end
end
