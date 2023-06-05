# frozen_string_literal: true

module Members
  class DashboardController < ApplicationController
    before_action :authorize

    def index
      @dates = Members::Date.not_expired.order(:datetime)
      @files = Document.member
    end

    private

    def authorize
      super(%i[members dashboard])
    end
  end
end
