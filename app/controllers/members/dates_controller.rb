class Members::DatesController < Members::MembersController
	before_filter :find_date, :only => [:edit, :update, :destroy]
	
	restrict_access_to_group :admin
	
  def new
    @date = Members::Date.new
  end

  def edit
  end

  def create
    @date = Members::Date.new(params[:members_date])

		if @date.save
			redirect_to members_root_path
		else
			render action: :new
		end
  end

  def update
  	if @date.update_attributes(params[:members_date])
			redirect_to members_root_path, notice: t("application.saved_changes")
		else
			render action: :edit
		end
  end

  def destroy
    @date.destroy
		
    redirect_to members_root_path
  end
	
	private
	
	def find_date
		@date = Members::Date.find(params[:id])
	end
end
