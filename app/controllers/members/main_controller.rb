class Members::MainController < Members::MembersController
  def index
		@dates = Members::Date.not_expired.order(:datetime)
		@files = Members::File.all
  end
end
