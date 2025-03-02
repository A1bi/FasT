# frozen_string_literal: true

class PhotosController < ApplicationController
  before_action :find_photo, only: %i[edit update destroy]
  before_action :find_gallery, only: %i[edit create update_positions]

  def edit; end

  def create
    @photo = authorize @photos.new(photo_params)
    head @photo.save ? :no_content : :unprocessable_entity
  end

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

  def update_positions
    @photos.unscope(:order).find(params[:ids]).each.with_index do |photo, position|
      photo.update(position:)
    end
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
    params.expect(photo: %i[gallery_id position text image])
  end
end
