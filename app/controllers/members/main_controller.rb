module Members
	class MainController < BaseController
	  def index
			@dates = Date.not_expired.order(:datetime)
			@files = File.all
	  end
	end
end
