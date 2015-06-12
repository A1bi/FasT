module Ticketing
  module OrdersHelper
    def prepopulated_text_field(f, name, key = name, email = false)
      value = (web? && @_member && @_member.respond_to?(key) ? @_member.send(key) : "")
      f.send("#{email ? 'email' : 'text'}_field", name, class: "field", value: value)
    end
    
    def format_billing_amount(amount)
      (amount > 0 ? "+" : "") + number_to_currency(amount)
    end
  end
end