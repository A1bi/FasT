# frozen_string_literal: true

require_shared_examples 'spam_filtering'

RSpec.describe 'NewsletterSubscribers' do
  describe 'POST #create' do
    subject { post newsletter_subscriber_path(params) }

    let(:subscriber_params) { { last_name: 'Foo', gender: 0, email: 'foo@bar.com', privacy_terms: 1 } }
    let(:comment) { '' }
    let(:params) { { newsletter_subscriber: subscriber_params, comment: } }

    # rubocop:disable RSpec/BeforeAfterAll
    before(:context) { create(:newsletter_subscriber_list, id: 1) }

    after(:context) { Newsletter::SubscriberList.delete_all }
    # rubocop:enable RSpec/BeforeAfterAll

    context 'with valid params' do
      it 'creates a subscriber' do
        expect { subject }.to change(Newsletter::Subscriber, :count).by(1)
        subscriber = Newsletter::Subscriber.last
        expect(subscriber.attributes)
          .to include(subscriber_params.slice(:last_name, :email, :gender).stringify_keys)
      end

      it 'redirects to the frontpage' do
        subject
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid params' do
      let(:subscriber_params) { { email: 'foo' } }

      it 'renders the form' do
        subject
        expect(response.body).to include('form action="/newsletter')
      end
    end

    it_behaves_like 'spam honeypot', Newsletter::Subscriber
    it_behaves_like 'spam param filter', Newsletter::Subscriber, :last_name
  end
end
