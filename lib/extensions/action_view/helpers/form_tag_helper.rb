# frozen_string_literal: true

module ActionView
  module Helpers
    module FormTagOptionsHelper
      private

      def extend_email_options!(options)
        options[:pattern] = FasT::EMAIL_REGEXP_JS
        options[:inputmode] = 'email'
        options[:title] = I18n.t('form_builder.email_field.title')
      end

      def extend_postal_code_options!(options)
        options[:pattern] = '\d{5}'
        options[:maxlength] = 5
        options[:inputmode] = 'numeric'
        options[:title] = I18n.t('form_builder.postal_code_field.title')
        options[:autocomplete] = 'postal-code'
      end
    end

    module FormBuilderExtensions
      include FormTagOptionsHelper

      def email_field(method, options = {})
        extend_email_options!(options)

        text_field(method, options)
      end

      def postal_code_field(method, options = {})
        extend_postal_code_options!(options)

        text_field(method, options)
      end
    end

    module FormTagHelperExtensions
      include FormTagOptionsHelper

      def email_field_tag(name, value = nil, options = {})
        extend_email_options!(options)

        text_field_tag(name, value, options)
      end

      def postal_code_field_tag(name, value = nil, options = {})
        extend_postal_code_options!(options)

        text_field_tag(name, value, options)
      end
    end

    FormBuilder.prepend FormBuilderExtensions
    FormTagHelper.prepend FormTagHelperExtensions
  end
end
