# frozen_string_literal: true

class GalleriesController < ApplicationController
  before_action :find_gallery, only: %i[show edit update destroy]

  def index
    @galleries = authorize Gallery.order(:position)
  end

  def show
    @photos = @gallery.photos
  end

  def new
    @gallery = authorize(Gallery.new)
  end

  def create
    @gallery = authorize(Gallery.new(gallery_params))

    if @gallery.save
      redirect_to edit_gallery_path(@gallery)
    else
      render :new
    end
  end

  def edit; end

  def update
    return render :edit unless @gallery.update(gallery_params)

    flash.notice = t('application.saved_changes')
    redirect_to edit_gallery_path(@gallery)
  end

  def destroy
    @gallery.destroy
    redirect_to galleries_path
  end

  private

  def find_gallery
    @gallery = authorize Gallery.find(params[:id])
  end

  def gallery_params
    params.require(:gallery).permit(:disclaimer, :position, :title)
  end
end
