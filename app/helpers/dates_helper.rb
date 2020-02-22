# frozen_string_literal: true

module DatesHelper
  def item_availability(date)
    return 'Discontinued' if date.event.sale_ended?
    return 'SoldOut' if date.sold_out?

    'InStock'
  end
end
