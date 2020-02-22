# frozen_string_literal: true

module DocumentManagement
  extend ActiveSupport::Concern

  included do
    before_action :find_document, only: %i[edit update destroy]
  end

  def new
    @document = authorize Document.new
  end

  def edit; end

  def create
    @document = authorize Document.new(document_params)
    @document.members_group = members_group

    if @document.save
      redirect_to redirect_path, notice: t('documents.created')
    else
      render :new
    end
  end

  def update
    if @document.update(document_params)
      redirect_to redirect_path, notice: t('application.saved_changes')
    else
      render :edit
    end
  end

  def destroy
    flash.notice = t('documents.destroyed') if @document.destroy

    redirect_to redirect_path
  end

  private

  def find_document
    @document = authorize Document.where(members_group: members_group)
                                  .find(params[:id])
  end

  def document_params
    params.require(:document).permit(:description, :title, :file)
  end
end
