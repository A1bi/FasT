# frozen_string_literal: true

module Ticketing
  class BankCharge < ApplicationRecord
    include BankTransaction

    belongs_to :submission, class_name: 'BankChargeSubmission', optional: true
    belongs_to :chargeable, polymorphic: true, autosave: true

    def mandate_id
      id
    end
  end
end
