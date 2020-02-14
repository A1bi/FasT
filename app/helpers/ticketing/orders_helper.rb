module Ticketing
  module OrdersHelper
    def prepopulated_text_field(form, name, key = name, email = false)
      value = action_name == 'new' ? current_user.try(key) : nil
      form.send("#{email ? 'email' : 'text'}_field", name,
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
