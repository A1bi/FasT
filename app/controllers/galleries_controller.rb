class GalleriesController < ApplicationController
  
  restrict_access_to_group :admin, :except => [:index, :show]
  
  before_filter :find_gallery, :only => [:show, :edit, :update, :destroy]
  
  def find_gallery
    @gallery = Gallery.find(params[:id])
  end
  
  
  def index
    @galleries = Gallery.order(:position)
    
    fresh_when last_modified: @galleries.maximum(:updated_at)
  end

  def show
    @photos = @gallery.photos
    
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
    if @gallery.update_attributes(params[:gallery])
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
  
	def sort
		params[:gallery].each_with_index do |id, index|
			Gallery.find(id).update_attribute(:position, index+1)
		end
		render :nothing => true
	end
end
