class GalleriesController < ApplicationController
  
  restrict_access_to_group :admin, :except => [:index, :show]
  
  before_filter :find_gallery, :only => [:show, :edit, :update, :destroy]
  
  def find_gallery
    @gallery = Gallery.find(params[:id])
  end
  
  
  def index
    @galleries = Gallery.order(:pos)
    
    fresh_when last_modified: @galleries.maximum(:updated_at)
  end

  def show
    @photos = @gallery.photos.order(:pos)
    
    fresh_when last_modified: @gallery.updated_at
  end
  
  def new
    @gallery = Gallery.new
  end
  
  def create
    @gallery = Gallery.new(params[:gallery])
    
    if !@gallery.save
      render :action => :new
    else
      redirect_to edit_gallery_path(@gallery)
    end
  end
  
  def edit
  end
  
  def update
    # update order of photos?
    if !params[:gallery][:pos].nil?
      params[:gallery][:pos].each do |id, pos|
        Photo.find(id).update_attribute(:pos, pos)
      end
      flash.notice = t("galleries.changed_order")
      
    # just update gallery info
    elsif @gallery.update_attributes(params[:gallery])
      flash.notice = t("application.saved_changes")
    else
      return render :action => :edit
    end
    
    redirect_to edit_gallery_path(@gallery)
  end
  
  def destroy
    @gallery.destroy
    redirect_to galleries_path
  end
  
end
