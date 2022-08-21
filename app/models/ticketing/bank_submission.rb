# frozen_string_literal: true

module Ticketing
  class BankSubmission < ApplicationRecord
    has_many :transactions,
             class_name: 'BankTransaction', foreign_key: :submission_id,
             dependent: :nullify, inverse_of: :submission
  end
end
