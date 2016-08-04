module Members
  class FilesController < BaseController
    before_filter :find_file, :only => [:edit, :update, :destroy]

    restrict_access_to_group :admin

    def new
      @file = Members::File.new
    end

    def edit
    end

    def create
      @file = Members::File.new(file_params)

      if @file.save
        redirect_to members_root_path
      else
        render action: :new
      end
    end

    def update
      if @file.update_attributes(file_params)
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
      @file = Members::File.find(params[:id])
    end

    def file_params
      params.require(:members_file).permit(:description, :title, :file)
    end
  end
end
