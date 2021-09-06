# frozen_string_literal: true

RSpec.shared_examples 'spam request handling' do |model|
  if model.respond_to?(:count)
    it 'does not create a record' do
      expect { subject }.not_to change(model, :count)
    end
  end

  it 'redirects to the frontpage' do
    subject
    expect(response).to redirect_to(root_path)
  end
end

RSpec.shared_examples 'spam honeypot' do |model|
  context 'with spam request' do
    context 'when comment is not empty' do
      let(:comment) { 'foo' }

      include_examples 'spam request handling', model
    end

    context 'when comment is a newline' do
      let(:comment) { "\n" }

      include_examples 'spam request handling', model
    end
  end
end

RSpec.shared_examples 'spam param filter' do |model, field_name|
  context 'with spam request' do
    let(:params) do
      params = super()
      params[model.model_name.param_key.to_sym][field_name] = value
      params
    end

    context 'when field contains a URL' do
      let(:value) { 'hello foo https://example.com hey' }

      include_examples 'spam request handling', model
    end
  end
end
