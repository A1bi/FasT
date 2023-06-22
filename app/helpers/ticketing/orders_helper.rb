# frozen_string_literal: true

module Ticketing
  module OrdersHelper
    def max_tickets_for_type(max_tickets, type)
      return max_tickets unless type.exclusive? && !current_user.admin?

      type.credit_left_for_member(current_user)
    end
  end
end
