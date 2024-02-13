# frozen_string_literal: true

module ActionView
  module Helpers # :nodoc:
    module TagHelperExtensions
      def tag(name = nil, options = nil, open = true, escape = true) # rubocop:disable Metrics/ParameterLists, Style/OptionalBooleanParameter
        super
      end
    end

    TagHelper.prepend TagHelperExtensions
  end
end
