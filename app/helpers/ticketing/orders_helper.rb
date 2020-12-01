# frozen_string_literal: true

module Ticketing
  module OrdersHelper
    def prepopulated_text_field(form, name, key = name, type = :text)
      value = action_name.in?(%w[new new_coupons]) ? current_user.try(key) : nil
      form.send("#{type}_field", name,
                class: 'field', value: value.to_s)
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
