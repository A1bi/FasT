class GbookController < ApplicationController
  restrict_access_to_group :admin, :only => [:edit, :update, :destroy]

  before_action :find_entry, :only => [:edit, :update, :destroy]

  def index
    @steps = 5
    @page = (params[:page].to_i < 1) ? 1 : params[:page].to_i
    @entries = GbookEntry.order(:id).reverse_order.limit(@steps).offset(@steps * (@page - 1))
  end

  def new
    @entry = GbookEntry.new
  end

  def create
    @entry = GbookEntry.new(entry_params)

    if @entry.save
      redirect_to gbook_entries_path
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @entry.update_attributes(entry_params)
      flash.notice = t("application.saved_changes")
    else
      return render :action => :edit
    end

    redirect_to edit_gbook_entry_path(@entry)
  end

  def destroy
    @entry.destroy
    redirect_to gbook_entries_path
  end

  private

  def find_entry
    @entry = GbookEntry.find(params[:id])
  end

  def entry_params
    params.require(:gbook_entry).permit(:author, :text)
  end
end
