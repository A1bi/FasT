module Ticketing
  class TicketPolicy < ApplicationPolicy
    def cancel?
      admin_or_retail?
    end

    def enable_resale?
      current_user_admin?
    end

    def transfer?
      admin_or_retail?
    end

    def update?
      current_user_admin?
    end

    def edit?
      update?
    end

    def finish_transfer?
      admin_or_retail?
    end

    def init_transfer?
      finish_transfer?
    end

    def printable?
      admin_or_retail?
    end

    private

    def admin_or_retail?
      current_user_admin? || retail_order?
    end

    def retail_order?
      if record.respond_to? :any?
        # check if all tickets belong to retail order
        record.all? { |r| retail_order?(r) }
      else
        # order or ticket.order
        order = record.is_a?(Order) ? record : record.order
        order.try(:store) && order.store == retail_store
      end
    end
  end
end