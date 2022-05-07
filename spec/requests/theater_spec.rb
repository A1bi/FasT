# frozen_string_literal: true

RSpec.describe 'Theater' do
  describe 'GET #index' do
    subject { get theater_path }

    it 'renders the main overview' do
      subject
      expect(response.body).to include('Unsere Theaterstücke')
    end
  end

  describe 'GET #show' do
    subject { get theater_play_path(slug:) }

    let(:event) { create(:event, :with_dates, identifier:) }
    let(:identifier) { nil }
    let(:slug) { event.slug }

    context 'with an event without corresponding record but template' do
      let(:slug) { :montevideo }

      it 'renders the corresponding template' do
        subject
        expect(response.body).to include('Haus in Montevideo')
      end
    end

    context 'with an event with corresponding record and template' do
      let(:identifier) { :gemetzel }

      it 'renders the corresponding template' do
        subject
        expect(response.body).to include('Gott des Gemetzels')
      end
    end

    context 'with an event without corresponding template' do
      let(:identifier) { :gemetzel_cochem }

      it 'returns a 404' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with an invalid slug' do
      let(:slug) { :foobar }

      it 'raises an exception which results in a 404' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
