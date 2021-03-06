# frozen_string_literal: true

module Newsletter
  class SubscriberList < ApplicationRecord
    has_many :subscribers, -> { confirmed }, dependent: :destroy,
                                             inverse_of: :subscriber_list
    has_and_belongs_to_many :newsletters

    validates :name, presence: true
  end
end
