class Members::MainController < Members::MembersController
  def index
		@dates = Members::Date.order(:datetime)
  end
end
