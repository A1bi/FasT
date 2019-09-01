class PhotosController < ApplicationController
  restrict_access_to_group :admin, :except => [:show]
  restrict_access_to_group :member, :only => [:show]

  before_action :find_photo, :only => [:edit, :update, :destroy, :show]
  before_action :find_gallery, :only => [:new, :edit, :create]

  def new
    @photo = @gallery.photos.new
  end

  def create
    @photo = @gallery.photos.new(photo_params)

    if !@photo.save
      render :action => "new"
    else
      redirect_to edit_gallery_path(@gallery)
    end
  end

  def show
    send_file @photo.image.path
  end

  def edit
  end

  def update
    if @photo.update_attributes(photo_params)
      redirect_to edit_gallery_path(params[:gallery_id])
    else
      render :action => "edit"
    end
  end

  def destroy
    @photo.destroy
    redirect_to edit_gallery_path(params[:gallery_id])
  end

  def sort
    photo = nil
    params[:photo].each_with_index do |id, index|
      photo = Photo.find(id)
      photo.update_column(:position, index+1)
    end
    photo.gallery.update_attribute(:updated_at, Time.now)

    head :ok
  end

  private

  def find_photo
    @photo = Photo.find(params[:id])
  end

  def find_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end

  def photo_params
    params.require(:photo).permit(:gallery_id, :position, :text, :image)
  end
end
