# frozen_string_literal: true

module Admin
  module NewslettersHelper
    def subscriber_list_with_count(list)
      "#{list.name} (#{number_with_delimiter(list.subscribers.count)})"
    end
  end
end
