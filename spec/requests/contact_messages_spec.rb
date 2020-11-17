# frozen_string_literal: true

require_shared_examples 'spam_honeypot'

RSpec.describe 'ContactMessages' do
  describe 'POST #create' do
    subject { post contact_messages_path(params) }

    let(:message_params) do
      { name: 'Foo', subject: 'Bar', email: 'foo@bar.com', content: 'foobar' }
    end
    let(:comment) { '' }
    let(:params) do
      { contact_message: message_params, comment: comment }
    end

    context 'valid params provided' do
      let(:message) { double.as_null_object }

      it 'sends a contact message notification' do
        expect(ContactMessage)
          .to receive(:new).with(message_params.stringify_keys)
                           .and_return(message)
        expect(message).to receive(:mail)
        subject
      end

      it 'redirects to the form' do
        subject
        expect(response).to redirect_to(contact_messages_path)
      end
    end

    context 'invalid params provided' do
      let(:message_params) { { email: 'foo' } }

      it 'renders the form' do
        subject
        expect(response.body).to include('form class="new_contact_message"')
      end
    end

    it_behaves_like 'spam honeypot'
  end
end
