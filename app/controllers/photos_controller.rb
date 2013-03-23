class PhotosController < ApplicationController
  restrict_access_to_group :admin
	
  before_filter :find_photo, :only => [:edit, :update, :destroy, :toggle_slide]
  before_filter :find_gallery, :only => [:new, :edit, :create]  
  
  def new
    @photo = @gallery.photos.new
  end
  
  def create
    @photo = @gallery.photos.new(params[:photo])
    
    if !@photo.save
      render :action => "new"
    else
      redirect_to edit_gallery_path(@gallery)
    end
  end
  
  def edit
  end
  
  def update
    if @photo.update_attributes(params[:photo])
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
		params[:photo].each_with_index do |id, index|
			Photo.find(id).update_attribute(:position, index+1)
		end
		render :nothing => true
	end
	
	def toggle_slide
		@photo.toggle_slide
		expire_fragment "photos_slides"
		
		redirect_to edit_gallery_path(params[:gallery_id]), :notice => t("photos.toggle_slide")[@photo.slide?]
	end
	
	private
	
  def find_photo
    @photo = Photo.find(params[:id])
  end
  
  def find_gallery
    @gallery = Gallery.find(params[:gallery_id])
  end
end