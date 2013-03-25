module Members
	class MainController < BaseController
	  def index
			@dates = Members::Date.not_expired.order(:datetime)
			@files = Members::File.all
	  end
	end
end
