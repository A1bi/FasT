# frozen_string_literal: true

RSpec.describe Ticketing::OrderMailer do
  let(:mailer) { described_class.with(params) }
  let(:html) { subject.html_part.decoded }
  let(:text) { subject.text_part.decoded }
  let(:params) { { order: } }
  let(:order) { create(:web_order, :with_purchased_coupons) }

  shared_examples 'basic email properties' do |subject_|
    context 'with a web order' do
      it 'renders the headers' do
        expect(subject.subject).to eq(subject_)
        expect(subject.to).to eq([order.email])
        expect(subject.from.count).to eq(1)
        expect(subject.from.first).to eq('noreply@theater-kaisersesch.de')
        expect(subject.reply_to.first).to eq('info@theater-kaisersesch.de')
      end
    end

    context 'without a web order' do
      let(:order) { create(:retail_order, :with_purchased_coupons) }

      it 'does not process the email' do
        expect(order).not_to receive(:email)
        expect(subject.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end

  describe '#confirmation' do
    subject { mailer.confirmation }

    before { allow(order).to receive(:signed_info).with(authenticated: true).and_return('boofar') }

    it_behaves_like 'basic email properties', 'Ihre Bestellung'

    shared_examples 'payment independent elements' do
      it 'contains the order action buttons' do
        expect(html).to include('Umbuchung', 'Stornierung', 'tickets/boofar')
      end

      it 'contains structured data' do
        expect(html).to include('application/ld+json', 'http://schema.org')
      end
    end

    shared_examples 'paid elements' do
      it 'attaches the tickets' do
        expect(subject.attachments.first.filename).to eq('Tickets.pdf')
        expect(text).to include('Sie finden Ihre Tickets')
      end

      it 'includes a wallet button' do
        expect(html).to include('Apple Wallet', 'add_to_wallet.png')
      end
    end

    context 'with a paid debit ticket order' do
      let(:order) { create(:web_order, :with_tickets, :charge_payment) }
      let(:debit) { order.open_bank_transaction }

      before { debit.update(amount: 11.22) }

      it 'contains the debit details' do
        expect(text).to include(
          'Betrag von 11,22 €', 'SEPA-Lastschrift', debit.name, "XXX#{debit.iban[-3..]}"
        )
      end

      it_behaves_like 'paid elements'
      it_behaves_like 'payment independent elements'
    end

    context 'with paid stripe order' do
      let(:order) { create(:web_order, :with_tickets, :stripe_payment) }

      it_behaves_like 'paid elements'
      it_behaves_like 'payment independent elements'

      it 'mentions Stripe payment method' do
        expect(text).to include('per Apple Pay bezahlt')
      end
    end

    context 'with an unpaid transfer ticket order' do
      let(:order) { create(:web_order, :with_tickets, :unpaid) }

      before do
        order.billing_account.update(balance: -4.5)
        allow(Settings.ticketing.target_bank_account).to receive(:iban).and_return('DE75512108001245126199')
      end

      it 'contains the transfer details' do
        expect(text).to include(
          'Bitte überweisen Sie den Betrag von 4,50 €',
          Settings.ticketing.target_bank_account.name,
          'DE75 5121 0800 1245 1261 99',
          "Bestellung #{order.number}"
        )
      end

      it 'does not attach the tickets' do
        expect(subject.attachments).to be_empty
        expect(text).not_to include('Sie finden Ihre Tickets')
      end

      it 'does not include a wallet button' do
        expect(html).not_to include('Apple Wallet', 'add_to_wallet.png')
      end

      it_behaves_like 'payment independent elements'
    end
  end

  describe '#cancellation' do
    subject { mailer.cancellation }

    let(:params) { { order:, cancellation:, refund_transaction: } }
    let(:order) { create(:web_order, :with_tickets, tickets_count:) }
    let(:cancellation) { create(:cancellation, tickets: [order.tickets[0]]) }
    let(:refund_transaction) { build(:bank_transaction, amount: -12.34) }
    let(:tickets_count) { 2 }

    it 'contains the refund amount' do
      expect(text).to include('Erstattung in Höhe von 12,34 €')
    end

    it 'contains the refund target details' do
      expect(text).to include(refund_transaction.name, "XXX#{refund_transaction.iban[-3..]}")
    end

    it 'mentions cancelled and valid tickets' do
      expect(text)
        .to include('Folgende Artikel wurden storniert',
                    'Folgende Artikel wurden nicht storniert und sind weiterhin gültig')
    end

    context 'when no valid tickets are left' do
      let(:tickets_count) { 1 }

      it 'mentions only cancelled tickets' do
        expect(text)
          .to include('Folgende Artikel wurden storniert', 'vollständig storniert')
        expect(text)
          .not_to include('nicht storniert')
      end
    end

    context 'when refund is transferred via Stripe' do
      let(:refund_transaction) { build(:stripe_refund, amount: 3.45) }

      it 'contains the refund amount and method' do
        expect(text).to include('Erstattung in Höhe von 3,45 € wird per Apple Pay')
      end
    end

    context 'when there is still an outstanding balance' do
      let(:order) { create(:web_order, :unpaid, :with_tickets, tickets_count:) }
      let(:refund_transaction) { nil }

      before { allow(order).to receive(:balance).and_return(-7.89) }

      it 'contains the outstanding amount' do
        expect(text).to include('noch offene Betrag', '7,89 €')
      end
    end
  end
end
