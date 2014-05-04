# encoding: utf-8

FasT::Application.routes.draw do

  # dates
  controller :dates, path: "termine", as: :dates do
    root action: :don_camillo, as: ""
  end

  # theater
  controller :theater, path: "theater", as: :theater do
    get "/", action: :index
    get "montevideo"
    get "hexenjagd"
    get "medicus"
    get "phantasus"
    get "jedermann"
  end

  # info
  controller :info, path: "info", as: :info do
    get "/", action: :index
    get "map"
    get "weather"
  end
  
  # static pages
  controller :static do
    get "geschichte", action: :history, as: :history
    get "impressum"
    get "satzung"
    get "agb"
    
    root action: :index
  end

  # resources
  scope path_names: { new: "neu", edit: "bearbeiten" } do
    
    # gbook
    resources :gbook_entries,
      controller: :gbook,
      path: "gästebuch",
      except: [:show] do
        collection do
          get "(:page)", action: :index, as: "", constraints: { page: /\d+/ }
        end
      end
      
    # galleries
    resources :galleries, path: "galerie" do
      collection do
        post "sort"
      end
      resources :photos, path: "fotos", except: [:index] do
        collection do
          post "sort"
        end
        member do
          put "toggle_slide"
        end
      end
    end
    
    resource :newsletter_subscriber, controller: :newsletter, path: :newsletter, only: [:create, :update, :destroy] do
      get :edit
    end
    
    namespace :admin, path: "vorstand" do
      resources :members_members, path: "mitglieder", except: [:show], controller: :members do
        member do
          post "reactivate", path: "reaktivieren"
        end
      end
    end
    
    namespace :ticketing, path: "" do
      scope path: "vorverkauf" do
        get "statistik" => "statistics#index", as: :statistics
        scope path: "bestellungen", type: :admin do
          resource :order, path: "", only: [] do
            member do
              get "neu", action: :new_admin, as: :new_admin
            end
            collection do
              post "enable-reservation-groups", action: :enable_reservation_groups, as: :enable_reservation_groups
            end
          end
          resources :orders, path: "", only: [:index, :show] do
            member do
              post :send_pay_reminder
              put :mark_as_paid
              put :approve
              post :cancel
              post :resend_tickets
            end
          end
        end
        controller :payments, path: "zahlungen", as: :payments do
          get "/", action: :index
          put :mark_as_paid
          put :approve
          post :submit
          get :sheet, path: "begleitzettel/:id"
        end
        resources :seats, path: "sitzplan", only: [:index, :create, :update] do
          collection do
            get :edit
            put :update_multiple
            delete :update_multiple, action: :destroy_multiple
          end
        end
        resources :blocks, path: "blöcke", except: [:index, :show]
        resources :coupons, path: "gutscheine" do
          member do
            post :mail
          end
        end
      end
      
      scope as: :retail, path: "vorverkaufsstelle" do
        scope path: "bestellungen", type: :retail do
          resource :order, path: "", only: [] do
            member do
              get "neu", action: :new_retail, as: :new
            end
          end
          resources :orders, path: "", only: [:index, :show] do
            member do
              post :cancel
            end
          end
        end
        scope module: :retail do
          get "login" => "sessions#new", as: :login
          post "login" => "sessions#create"
          get "logout" => "sessions#destroy", as: :logout
        end
      end
      
      resource :order, path: "tickets", type: :web, only: [] do
        member do
          get "bestellen", action: :new, as: :new
        end
        collection do
          post "redeem", action: :redeem_coupon, as: :redeem_coupon
        end
      end
    end
    
    namespace :members, path: "mitglieder" do
      resource :member, path: "mitgliedschaft", controller: :member, only: [:edit, :update] do
        member do
          get "activate", path: "aktivieren"
          put "finish_activation"
          get "forgot_password", path: "passwort_vergessen"
          post "reset_password"
        end
      end
      resources :dates, path: "termine", except: [:show]
      resources :files, path: "dateien", except: [:index, :show]
      
      get "login" => "sessions#new", as: :login
      post "login" => "sessions#create"
      get "logout" => "sessions#destroy", as: :logout
      
      root to: "main#index"
    end
    
  end
  
  scope path: :api do
    scope module: :api do
      resources :orders, only: [:create] do
        member do
          post "mark_paid", action: :mark_as_paid
        end
        collection do
          get "retail/:store_id", action: :retail
          get "current_date"
          get "number/:number", action: :by_number
        end
      end
      scope controller: :tickets, path: :tickets do
        post :check_in
      end
      get "events/current", as: "current_event"
      get "seats" => "seats#index"
      resources :purchases, only: [:create] do
        collection do
          post :unlock_seats
        end
      end
    end
    
    scope module: :passbook_controllers, controller: :passbook, path: :passbook, constraints: { pass_type_id: /([\w\d\-\.])+/ } do
      root as: :passbook_root, to: redirect("/")
      scope path: :v1 do
        scope "passes/:pass_type_id" do
          get ":serial_number", action: :show_pass
        end
        scope "devices/:device_id/registrations/:pass_type_id" do
          scope ":serial_number" do
            post action: :register_device
            delete action: :unregister_device
          end
          get "/", action: :modified_passes
        end
        post "log", action: :log
      end
    end
    
  end

end
