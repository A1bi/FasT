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
      resources :photos, :path => "fotos" do
				collection do
					post "sort"
				end
			end
		end
    
  end
	
	controller :tickets, :path => "tickets" do
		get "bestellen", :action => :new, :as => :new_tickets
		get "seats", :as => :tickets_seats
		post "reserve_seat", :as => :tickets_reserve_seat
		post "update_order", :as => :tickets_update_order
		get "order_info", :as => :tickets_order_info
	end
  
  get "login" => "sessions#new", :as => :login
  post "login" => "sessions#create"
  get "logout" => "sessions#destroy", :as => :logout
	
	namespace :admin, :path => "vorstand" do
		resources :seats, :path => "sitzplan", :except => [:new]
	end

end
