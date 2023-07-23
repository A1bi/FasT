# frozen_string_literal: true

module EventsHelper
  include PhotosHelper

  def structured_data(event, locals = {})
    locals[:event] = event
    locals[:image] = event_logo_path(event)

    tag.script type: 'application/ld+json' do
      raw render(partial: 'events/structured_data', formats: :json, locals:) # rubocop:disable Rails/OutputSafety
    end
  end

  def question_answer(question, &)
    render 'faq_question_answer', { question: }, &
  end

  def item_availability(date)
    availability = if date.event.sale_ended?
                     'Discontinued'
                   elsif date.sold_out?
                     'SoldOut'
                   else
                     'InStock'
                   end
    schema_prefixed(availability)
  end

  def event_status(date)
    schema_prefixed(date.cancelled? ? 'EventCancelled' : 'EventScheduled')
  end

  def schema_prefixed(entity)
    "#{schema_context}/#{entity}"
  end

  def schema_context
    'http://schema.org'
  end
end
