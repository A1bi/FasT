class GbookController < ApplicationController
  
  restrict_access_to_group :admin, :only => [:edit, :update, :destroy]
  
  before_filter :define_codes, :only => [:new, :create]
  before_filter :find_entry, :only => [:destroy]
  
  def define_codes
    @codes = ["MBSD", "KMPY", "LRWK", "T4A1", "S74P", "ZN6X", "FGRN", "KD5W", "ZUS5", "H73K"]
    @codeNr = rand(@codes.count - 1)
  end
  
  def find_entry
    @entry = GbookEntry.find(params[:id])
  end
  
  
  def index
    @page = (params[:page].to_i < 1) ? 1 : params[:page].to_i
    steps = 5
    
    @pages = (GbookEntry.count.to_f / steps.to_f).ceil;
    @entries = GbookEntry.order(:id).reverse_order.limit(steps).offset(steps * (@page - 1)).all
    
    fresh_when last_modified: @entries.first.updated_at
  end

  def new
    @entry = GbookEntry.new
  end
  
  def create
    @entry = GbookEntry.new(params[:gbook_entry])
    
    @entry.valid?
    if @codes[params[:add][:codeNr].to_i] != params[:add][:code].upcase
      @entry.errors[:base] << t("gbook.wrong_code")
    end
    
    if @entry.errors.any?
      render :action => "new"
    else
      @entry.save
      redirect_to gbook_entries_path
    end
  end
  
  def destroy
    @entry.destroy
    redirect_to gbook_entries_path
  end
end
