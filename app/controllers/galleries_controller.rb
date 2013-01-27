class GalleriesController < ApplicationController
  
  before_filter :find_gallery, :only => [:edit, :update]
  
  def find_gallery
    @gallery = Gallery.find(params[:id])
  end
  
  
  def index
    @galleries = Gallery.order(:pos)
    
    fresh_when last_modified: @galleries.maximum(:updated_at)
  end

  def show
    @gallery = Gallery.find(params[:id])
    @photos = @gallery.photos.order(:pos)
    
    fresh_when last_modified: @photos.maximum(:updated_at)
  end
  
  def new
    @gallery = Gallery.new
  end
  
  def create
    @gallery = Gallery.new(params[:gallery])
    
    if !@gallery.save
      render :action => "new"
    else
      redirect_to galleries_path
    end
  end
  
  def edit
  end
  
  def update
    if @gallery.update_attributes(params[:gallery])
      redirect_to galleries_path
    else
      render :action => "edit"
    end
  end
  
end
