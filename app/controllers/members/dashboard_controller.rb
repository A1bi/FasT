module Members
  class DashboardController < ApplicationController
    def index
      authorize %i[members dashboard]

      @dates = Members::Date.not_expired.order(:datetime)
      @files = Document.member
    end
  end
end
