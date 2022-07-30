# frozen_string_literal: true

module Ticketing
  class BankCharge < ApplicationRecord
    include BankTransaction

    belongs_to :submission, class_name: 'BankChargeSubmission', optional: true

    def mandate_id
      id
    end
  end
end
