class Admin::MembersController < Admin::AdminController
  def index
    @members = Member.order(:last_name).order(:first_name)
  end
end
