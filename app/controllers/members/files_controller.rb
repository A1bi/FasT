module Members
	class FilesController < BaseController
		before_filter :find_file, :only => [:edit, :update, :destroy]
	
		restrict_access_to_group :admin
	
		def new
			@file = File.new
		end
	
	  def edit
	  end

	  def create
	    @file = File.new(params[:members_file])

			if @file.save
				redirect_to members_root_path
			else
				render action: :new
			end
	  end

	  def update
	  	if @file.update_attributes(params[:members_file])
				redirect_to members_root_path, notice: t("application.saved_changes")
			else
				render action: :edit
			end
	  end

	  def destroy
	    @file.destroy
		
	    redirect_to members_root_path
	  end
	
		private
	
		def find_file
			@file = File.find(params[:id])
		end
	end
end
