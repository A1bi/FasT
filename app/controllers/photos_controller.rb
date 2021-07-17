# frozen_string_literal: true

class PhotosController < ApplicationController
  before_action :find_photo, only: %i[edit update destroy show]
  before_action :find_gallery, only: %i[index new edit create]

  def index; end

  def new
    @photo = authorize @photos.new
  end

  def create
    @photo = authorize @photos.new(photo_params)
    head @photo.save ? :no_content : :unprocessable_entity
  end

  def show
    send_file @photo.image.path
  end

  def edit; end

  def update
    success = @photo.update(photo_params)
    respond_to do |format|
      format.json { head success ? :no_content : :unprocessable_entity }
      format.html do
        return render :edit unless success

        redirect_to edit_gallery_photo_path(@photo.gallery, @photo), notice: t('application.saved_changes')
      end
    end
  end

  def destroy
    @photo.destroy
    redirect_to edit_gallery_path(params[:gallery_id])
  end

  private

  def find_photo
    @photo = authorize(Photo.find(params[:id]))
  end

  def find_gallery
    @gallery = Gallery.find(params[:gallery_id])
    @photos = authorize @gallery.photos
  end

  def photo_params
    params[:photo][:image] = params[:photo][:image].last if params.dig(:photo, :image).is_a? Array
    params.require(:photo).permit(:gallery_id, :position, :text, :image)
  end
end
