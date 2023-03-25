# frozen_string_literal: true

module Ticketing
  class OrderAddressFormBuilder < ActionView::Helpers::FormBuilder
    def text_field(attribute, input_options = {})
      input_options[:value] = current_user.try(attribute) if prepopulate?
      input_options[:class] = :field
      render_field_view(attribute) do
        super(attribute, input_options)
      end
    end

    def gender_select
      render_field_view(:gender) do
        select(:gender, @template.options_for_select(gender_options, preselected_gender))
      end
    end

    private

    def render_field_view(attribute, &)
      @template.render('ticketing/orders/field', label: human_attribute_name(attribute), &)
    end

    def gender_options
      genders = Ticketing::Web::Order.human_attribute_name(:genders)
      [['', ''], *genders.map.with_index { |g, i| [g, i] }]
    end

    def preselected_gender
      return nil unless prepopulate?

      Members::Member.genders.index(current_user.gender.to_sym)
    end

    def prepopulate?
      @template.controller.action_name.in?(%w[new new_coupons]) &&
        @template.user_signed_in? && current_user.member?
    end

    def human_attribute_name(attribute)
      Ticketing::Web::Order.human_attribute_name(attribute)
    end

    def current_user
      @template.current_user
    end
  end
end
