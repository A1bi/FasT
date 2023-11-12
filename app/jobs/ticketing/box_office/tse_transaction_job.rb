# frozen_string_literal: true

module Ticketing
  module BoxOffice
    class TseTransactionJob < ApplicationJob
      def perform(purchase:)
        TseTransactionCreateService.new(purchase).execute if Settings.tse.enabled
      end
    end
  end
end
