# encoding: utf-8

class PhotosController < ApplicationController
  
  before_filter :find_photo, :only => [:edit, :update, :destroy]
  before_filter :find_gallery, :only => [:new, :edit, :create]
  
  def find_photo
    @photo = Photo.find(params[:id])
  end
  
  def find_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end
  
  
  def new
    @photo = @gallery.photos.new
  end
  
  def create
    @photo = @gallery.photos.new(params[:photo])
    
    if !@photo.save
      render :action => "new"
    else
      redirect_to gallery_path(@photo.gallery)
    end
  end
  
  def edit
  end
  
  def update
    if @photo.update_attributes(params[:photo])
      redirect_to galleries_path
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @photo.destroy
    flash.notice = "Das Foto wurde erfolgreich gelöscht"
    redirect_to edit_gallery_path(params[:gallery_id])
  end
  
end