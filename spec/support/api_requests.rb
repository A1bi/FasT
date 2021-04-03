# frozen_string_literal: true

module ApiRequestHelpers
  def post_json(path, options = {})
    post path, params: options[:params]&.to_json,
               headers: { CONTENT_TYPE: 'application/json' }
  end

  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include ApiRequestHelpers
end
