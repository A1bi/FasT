# frozen_string_literal: true

module ActionView
  module Helpers
    module EmailTagOptionsHelper
      private

      def extend_options!(options)
        options[:pattern] = FasT::EMAIL_REGEXP_JS
        options[:inputmode] = 'email'
        options[:title] = I18n.t('form_builder.email_field.title')
      end
    end

    module FormBuilderExtensions
      include EmailTagOptionsHelper

      def email_field(method, options = {})
        extend_options!(options)

        text_field(method, options)
      end
    end

    module FormTagHelperExtensions
      include EmailTagOptionsHelper

      def email_field_tag(name, value = nil, options = {})
        extend_options!(options)

        text_field_tag(name, value, options)
      end
    end

    FormBuilder.prepend FormBuilderExtensions
    FormTagHelper.prepend FormTagHelperExtensions
  end
end
