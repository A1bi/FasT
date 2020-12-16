# frozen_string_literal: true

RSpec.shared_examples 'spam honeypot' do |model|
  context 'with spam request' do
    shared_examples 'spam request handling' do
      if model
        it 'does not create a record' do
          expect { subject }.not_to change(model, :count)
        end
      end

      it 'redirects to the frontpage' do
        subject
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when comment is not empty' do
      let(:comment) { 'foo' }

      include_examples 'spam request handling'
    end

    context 'when comment is a newline' do
      let(:comment) { "\n" }

      include_examples 'spam request handling'
    end
  end
end
