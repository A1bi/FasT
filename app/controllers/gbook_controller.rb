class GbookController < ApplicationController
  def entries
    @page = (params[:page].to_i < 1) ? 1 : params[:page].to_i
    steps = 5
    
    @pages = (GbookEntry.count.to_f / steps.to_f).ceil;
    @entries = GbookEntry.order(:id).reverse_order.limit(steps).offset(steps * (@page - 1)).all
    
    fresh_when last_modified: @entries.first.updated_at
  end

  def new
  end
  
  def create
    @entry = GbookEntry.new(params[:entry])
    
    if @entry.save
      redirect_to gbook_entries_path
    end
  end
end
