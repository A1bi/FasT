module Ticketing
  module OrdersHelper
    def prepopulated_text_field(form, name, key = name, email = false)
      value = web? ? current_user.try(key) : nil
      form.send("#{email ? 'email' : 'text'}_field", name,
                class: 'field', value: value.to_s)
    end

    def tickets_colspan(show_check_ins)
      show_check_ins ? 8 : 7
    end

    def max_tickets_for_type(max_tickets, type)
      return max_tickets unless type.exclusive? && !admin?

      type.credit_left_for_member(current_user)
    end
  end
end
