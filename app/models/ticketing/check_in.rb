# frozen_string_literal: true

module Ticketing
  class CheckIn < ApplicationRecord
    RETROACTIVE_AFTER_EVENT_DATE = 2.hours

    belongs_to :ticket, touch: true
    belongs_to :checkpoint, optional: true
    enum :medium, %i[unknown web retail passbook box_office box_office_direct]

    validates :date, :medium, presence: true

    class << self
      def medium_index(medium)
        media.values.index(medium.to_s)
      end
    end

    def medium=(medium)
      # check if medium is an integer or an integer inside a string
      if medium.is_a?(Integer) || medium.to_i.to_s == medium
        super(self.class.media.values[medium])
        return
      end

      super
    end

    def retroactive?
      date > ticket.date.date + RETROACTIVE_AFTER_EVENT_DATE
    end
  end
end
