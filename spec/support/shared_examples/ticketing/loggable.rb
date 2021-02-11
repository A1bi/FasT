# frozen_string_literal: true

RSpec.shared_examples 'loggable' do
  describe 'associations' do
    it {
      expect(subject)
        .to have_many(:log_events).inverse_of(:loggable).dependent(:destroy)
    }
  end
end

RSpec.shared_examples 'creates a log event' do |event|
  let(:info) { {} }

  it 'creates a log event' do
    expect { subject }.to change(loggable.log_events, :count).by(1)
    log_event = loggable.log_events.last
    expect(log_event.action).to eq(event.to_s)
    expect(log_event.info).to eq(info)
  end
end

RSpec.shared_examples 'creates a log event for a new record' do |event|
  let(:info) { {} }

  it 'creates a log event' do
    subject
    expect(loggable.log_events.size).to eq(1)
    log_event = loggable.log_events.last
    expect(log_event.action).to eq(event.to_s)
    expect(log_event.info).to eq(info)
  end
end

RSpec.shared_examples 'does not create a log event' do
  it 'does not create a log event' do
    expect { subject }.not_to change(Ticketing::LogEvent, :count)
  end
end
