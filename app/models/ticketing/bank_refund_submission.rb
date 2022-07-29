# frozen_string_literal: true

module Ticketing
  class BankRefundSubmission < ApplicationRecord
    has_many :refunds, class_name: 'BankRefund', foreign_key: :submission_id,
                       dependent: :nullify, inverse_of: :submission
  end
end
