class PhotosController < ApplicationController
  before_action :find_photo, only: %i[edit update destroy show]
  before_action :find_gallery, only: %i[new edit create]

  def new
    @photo = authorize @gallery.photos.new
  end

  def create
    @photo = authorize @gallery.photos.new(photo_params)

    return render :new unless @photo.save

    redirect_to edit_gallery_path(@gallery)
  end

  def show
    send_file @photo.image.path
  end

  def edit; end

  def update
    return render :edit unless @photo.update(photo_params)

    redirect_to edit_gallery_path(params[:gallery_id])
  end

  def destroy
    @photo.destroy
    redirect_to edit_gallery_path(params[:gallery_id])
  end

  def sort
    params[:photo].each.with_index(1) do |id, i|
      authorize(Photo.find(id)).update(position: i)
    end

    head :ok
  end

  private

  def find_photo
    @photo = authorize(Photo.find(params[:id]))
  end

  def find_gallery
    @gallery = authorize(Gallery.find(params[:gallery_id]))
  end

  def photo_params
    params.require(:photo).permit(:gallery_id, :position, :text, :image)
  end
end
