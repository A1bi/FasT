module Ticketing
  module OrdersHelper
    def prepopulated_text_field(f, name, key = name, email = false)
      value = (web? && @_member && @_member.respond_to?(key) ? @_member.send(key) : "")
      f.send("#{email ? 'email' : 'text'}_field", name, class: "field", value: value)
    end

    def tickets_colspan
      @show_check_ins ? 8 : 7
    end
  end
end
