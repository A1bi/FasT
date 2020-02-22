# frozen_string_literal: true

module Members
  class Family < ApplicationRecord
    has_many :members, dependent: :nullify
    has_many :sepa_mandates, through: :members

    def destroy_if_empty
      destroy if members.empty?
    end
  end
end
