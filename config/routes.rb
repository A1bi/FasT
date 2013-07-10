# encoding: utf-8

FasT::Application.routes.draw do

  # dates
  controller :dates, :path => "termine", :as => :dates do
    root :action => :jedermann, :as => ""
  end

  # theater
  controller :theater, :path => "theater", :as => :theater do
    get "/", :action => :index
    get "montevideo"
    get "hexenjagd"
    get "medicus"
    get "phantasus"
    get "jedermann"
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
  		resources :members_members, :path => "mitglieder", :except => [:show], :controller => :members do
        member do
          post "reactivate", :path => "reaktivieren"
        end
      end
  	end
    
    namespace :ticketing, :path => "vorverkauf" do
      get "statistik" => "statistics#index"
      resources :event_dates, :path => "termine", :only => [:index, :show, :new], :controller => :dates
			resources :seats, :path => "sitzplan", :only => [:index, :create, :update] do
        collection do
          put :update_multiple
          delete :update_multiple, :action => :destroy_multiple
        end
      end
      resources :blocks, :path => Rack::Utils.escape("blöcke"), :except => [:index, :show]
      resources :reservations, :only => [] do
        collection do
          put :update
          delete :destroy
        end
      end
    end
		
		namespace :members, :path => "mitglieder" do
			resource :member, :path => "mitgliedschaft", :controller => :member, :only => [:edit, :update] do
				member do
					get "activate", :path => "aktivieren"
					put "finish_activation"
          get "forgot_password", :path => "passwort_vergessen"
          post "reset_password"
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
    get "vorverkaufsstelle", :action => :new_retail, :as => :new_retail_order
    get "vorverkaufsstelle/login", :action => :retail_login, :as => :retail_order_login
    post "vorverkaufsstelle/login", :action => :retail_login_check, :as => :retail_order_login
	end
	
  scope :path => :api do
    scope :module => :api do
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
    
    scope :module => Passbook::Controllers, :controller => :passbook , :path => "passbook/v1", constraints: { pass_type_id: /([\w\d\-\.])+/ } do
      scope "passes/:pass_type_id" do
        get ":serial_number", :action => :show_pass
      end
      scope "devices/:device_id/registrations/:pass_type_id" do
        scope ":serial_number" do
          post :action => :register_device
          delete :action => :unregister_device
        end
        get "/", :action => :modified_passes
      end
      post "log", :action => :log
    end
    
  end

end
