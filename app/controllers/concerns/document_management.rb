module DocumentManagement
  extend ActiveSupport::Concern

  included do
    before_action :find_document, :only => [:edit, :update, :destroy]

    restrict_access_to_group :admin
  end

  def new
    @document = Document.new
  end

  def edit
  end

  def create
    puts members_group
    @document = Document.new(document_params)
    @document.members_group = members_group

    if @document.save
      redirect_to redirect_path
    else
      render action: :new
    end
  end

  def update
    if @document.update_attributes(document_params)
      redirect_to redirect_path, notice: t("application.saved_changes")
    else
      render action: :edit
    end
  end

  def destroy
    @document.destroy

    redirect_to redirect_path
  end

  private

  def find_document
    @document = Document.where(members_group: members_group).find(params[:id])
  end

  def document_params
    params.require(:document).permit(:description, :title, :file)
  end
end
