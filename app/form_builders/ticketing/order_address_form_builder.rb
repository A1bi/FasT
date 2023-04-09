# frozen_string_literal: true

module Ticketing
  class OrderAddressFormBuilder < ActionView::Helpers::FormBuilder
    %i[text phone].each do |type|
      define_method("#{type}_field") do |attribute, input_options = {}|
        input_options[:value] = prepopulated_value(attribute)
        input_options[:class] = :field

        render_field_view(attribute) do
          super(attribute, input_options)
        end
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
      return if (gender = prepopulated_value(:gender)).nil?

      if prepopulate_from_template_order?
        gender
      else
        Members::Member.genders.index(gender.to_sym)
      end
    end

    def prepopulate_from_template_order?
      @template.controller.action_name.in?(%w[new_privileged]) && current_user.admin? &&
        template_order.present?
    end

    def prepopulate_from_member?
      @template.controller.action_name.in?(%w[new new_coupons]) &&
        @template.user_signed_in? && current_user.member?
    end

    def prepopulated_value(attribute)
      if prepopulate_from_template_order?
        template_order.public_send(attribute)
      elsif prepopulate_from_member?
        current_user.try(attribute)
      end
    end

    def human_attribute_name(attribute)
      Ticketing::Web::Order.human_attribute_name(attribute)
    end

    def template_order
      options[:template_order]
    end

    def current_user
      @template.current_user
    end
  end
end
