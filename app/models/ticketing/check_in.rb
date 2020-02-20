module Ticketing
  class CheckIn < ApplicationRecord
    belongs_to :ticket, touch: true
    belongs_to :checkpoint, optional: true
    enum medium: %i[unknown web retail passbook box_office box_office_direct]

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
  end
end
