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
      :except => [:show] do
        collection do
					get "(:page)", :action => :index, :as => "", :constraints => { :page => /\d+/ }
				end
      end
      
    # galleries
    resources :galleries, :path => "galerie" do
			collection do
				post "sort"
			end
      resources :photos, :path => "fotos", :except => [:index] do
				collection do
					post "sort"
				end
				member do
					put "toggle_slide"
				end
			end
		end
    
  	namespace :admin, :path => "vorstand" do
  		resources :members_members, :path => "mitglieder", :except => [:show], :controller => :members
			resources :seats, :path => "sitzplan", :except => [:new, :edit, :show]
  	end
		
		namespace :members, :path => "mitglieder" do
			resource :member, :path => "mitgliedschaft", :controller => :member, :only => [:edit, :update] do
				member do
					get "activate", :path => "aktivieren"
					put "finish_activation"
				end
			end
			resources :dates, :path => "termine", :except => [:show]
			resources :files, :path => "dateien", :except => [:index, :show]
			
			get "login" => "sessions#new", :as => :login
			post "login" => "sessions#create"
			get "logout" => "sessions#destroy", :as => :logout
			
			root :to => "main#index"
		end
    
  end
	
	controller :orders, :path => "tickets" do
		get "bestellen", :action => :new, :as => :new_order
	end
	
  namespace :api do
    resources :orders, :only => [:create] do
      member do
        post "mark_paid"
      end
      collection do
        get "retail/:store_id", :action => :retail
      end
    end
    get "events/current", :as => "current_event"
  end

end
