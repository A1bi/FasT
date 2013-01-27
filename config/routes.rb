# encoding: utf-8

FasT::Application.routes.draw do

  # dates
  get "termine" => "dates#jedermann", :as => "dates"

  # theater
  controller :theater, :path => "theater", :as => :theater do
    get "/", :action => :index
    get "montevideo"
    get "hexenjagd"
    get "medicus"
    get "phantasus"
  end

  # info
  controller :info, :path => "info", :as => :info do
    get "/", :action => :index
    get "map"
    get "weather"
  end
  
  # static pages
  controller :static do
    get "geschichte", :action => :history, :as => :history
    get "impressum"
    get "satzung"
    get "agb"
    
    root :action => :index
  end

  # resources
  scope :path_names => { :new => "neu", :edit => "bearbeiten" } do
    
    # gbook
    resources :gbook_entries,
      :controller => :gbook,
      :path => Rack::Utils.escape("gästebuch"),
      :only => [:new, :create] do
        get "(:page)", :action => :index, :as => "", :on => :collection, :constraints => { :page => /\d+/ }
      end
      
    # galeries
    resources :galleries, :path => "galerie" do
      resources :photos, :path => "fotos"
    end
    
  end

end
