# frozen_string_literal: true

module Ticketing
  class BankRefund < ApplicationRecord
    include BankTransaction

    belongs_to :submission, class_name: 'BankRefundSubmission', optional: true
  end
end
