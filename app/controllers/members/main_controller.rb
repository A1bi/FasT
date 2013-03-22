class Members::MainController < Members::MembersController
  def index
		@dates = Members::Date.not_expired.order(:datetime)
  end
end
