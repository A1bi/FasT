module Members
  class MainController < BaseController
    def index
      @dates = Members::Date.not_expired.order(:datetime)
      @files = Document.member
    end
  end
end
