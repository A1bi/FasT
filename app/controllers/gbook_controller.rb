# encoding: utf-8

class GbookController < ApplicationController
  
  restrict_access_to_group :admin, :only => [:edit, :update, :destroy]
  
  before_filter :define_codes, :only => [:new, :create]
  
  def define_codes
    @codes = ["MBSD", "KMPY", "LRWK", "T4A1", "S74P", "ZN6X", "FGRN", "KD5W", "ZUS5", "H73K"]
    @codeNr = rand(@codes.count - 1)
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

    if @codes[params[:add][:codeNr].to_i] != params[:add][:code].upcase
      flash.now.alert = "Der Code stimmt nicht mit der Grafik überein!"
    elsif !@entry.save
      flash.now.alert = "Bitte füllen Sie alle Felder aus!"
    end
    
    if flash.now[:alert]
      render :action => "new"
    else
      redirect_to gbook_entries_path
    end
  end
end
