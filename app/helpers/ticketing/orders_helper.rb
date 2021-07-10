# frozen_string_literal: true

module Ticketing
  module OrdersHelper
    def prepopulated_text_field(form, name, key: name, type: :text, options: {})
      value = action_name.in?(%w[new new_coupons]) ? current_user.try(key) : nil
      options[:class] = 'field'
      options[:value] = value.to_s
      form.send("#{type}_field", name, options)
    end

    def preselected_gender
      return nil unless action_name.in?(%w[new new_coupons]) && user_signed_in? && current_user.member?

      Members::Member.genders.index(current_user.gender.to_sym)
    end

    def tickets_colspan(show_check_ins)
      show_check_ins ? 8 : 7
    end

    def max_tickets_for_type(max_tickets, type)
      return max_tickets unless type.exclusive? && !current_user.admin?

      type.credit_left_for_member(current_user)
    end
  end
end
