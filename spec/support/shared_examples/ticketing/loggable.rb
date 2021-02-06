# frozen_string_literal: true

RSpec.shared_examples 'loggable' do
  describe 'associations' do
    it {
      expect(subject)
        .to have_many(:log_events).inverse_of(:loggable).dependent(:destroy)
    }
  end
end

RSpec.shared_examples 'creates a log event' do |event, info|
  it 'creates a log event' do
    expect { subject }.to change(loggable.log_events, :count).by(1)
    log_event = loggable.log_events.last
    expect(log_event.name).to eq(event.to_s)
    expect(log_event.info).to eq(info || {})
  end
end

RSpec.shared_examples 'does not create a log event' do
  it 'does not create a log event' do
    expect { subject }.not_to change(Ticketing::LogEvent, :count)
  end
end
