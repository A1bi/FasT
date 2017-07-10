# encoding: utf-8

FasT::Application.routes.draw do

  # dates
  scope controller: :dates, path: "termine", as: :dates do
    root action: :magdalena, as: ""
  end

  # theater
  scope controller: :theater, path: "theater", as: :theater do
    get "/", action: :index
    get "montevideo"
    get "hexenjagd"
    get "medicus"
    get "phantasus"
    get "jedermann"
    get "don-camillo-und-peppone", action: :don_camillo, as: :don_camillo
    get "ladykillers"
    get "die-drachenjungfrau", action: :drachenjungfrau, as: :drachenjungfrau
    get "der-besuch-der-alten-dame", action: :alte_dame, as: :alte_dame
    get "magdalena-himmelstürmerin", action: :magdalena, as: :magdalena
  end

  # info
  scope controller: :info, path: "faq", as: :info do
    get "/", action: :index
    get "map"
    get "map_fall"
    get "weather"
  end
  get "info", to: redirect("faq")

  # static pages
  scope controller: :static do
    get "impressum"
    get "satzung"
    #get "agb"
    get "datenschutz", action: :privacy, as: :privacy

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
          get "download"
          patch "toggle_slide"
        end
      end
    end

    resource :newsletter_subscriber, controller: :newsletter, path: :newsletter, only: [:create, :update, :destroy] do
      get :edit
    end

    namespace :admin, path: "vorstand" do
      resources :newsletters do
        member do
          post :deliver
        end
        resources :images, controller: :newsletter_images, only: [:create, :destroy]
      end
      resources :members_members, path: "mitglieder", except: [:show], controller: :members do
        member do
          patch :reactivate, path: "reaktivieren"
        end
      end
    end

    namespace :ticketing, path: "" do

      concern :ticketable do
        resource :tickets, only: [] do
          collection do
            patch :cancel, path: "stornieren"
            patch :enable_resale
            get :transfer, path: "umbuchen"
            get :edit, path: "bearbeiten"
            patch :update
            post :init_transfer
            patch :finish_transfer
            get :printable
          end
        end
      end

      scope path: "vorverkauf" do
        scope controller: :statistics, path: "statistik", as: :statistics do
          get "/", action: :index
          get "seats", action: :seats, as: :seats
          get "chart_data", action: :chart_data, as: :chart_data
        end
        scope path: "bestellungen", type: :admin do
          resource :order, path: "", only: [] do
            member do
              get "neu", action: :new_admin, as: :new_admin
            end
            collection do
              post "enable-reservation-groups", action: :enable_reservation_groups, as: :enable_reservation_groups
            end
          end
          resources :orders, path: "", only: [:index, :show], concerns: :ticketable do
            member do
              post :send_pay_reminder
              patch :mark_as_paid
              patch :approve
              post :resend_tickets
              get :seats
              post :create_billing
            end
            collection do
              get :search, path: "suche"
            end
          end
        end
        scope controller: :payments, path: "zahlungen", as: :payments do
          get "/", action: :index
          patch :mark_as_paid
          patch :approve
          post :submit
          get :submission_file, path: "sepa_auftrag/:id"
        end
        resources :seats, path: "sitzplan", only: [:index, :create] do
          collection do
            get :edit
            scope constraints: { format: :json } do
              put :update
              delete :destroy
            end
          end
        end
        resources :blocks, path: "blöcke", except: [:index, :show]
        resources :coupons, path: "gutscheine" do
          member do
            post :mail
          end
        end
      end

      scope as: :retail, path: "vorverkaufsstelle", type: :retail do
        root to: redirect("/vorverkaufsstelle/bestellungen/neu"), type: ""
        get "statistik" => "statistics#index_retail", as: :statistics
        scope path: "bestellungen" do
          resource :order, path: "", only: [] do
            member do
              get "neu", action: :new_retail, as: :new
            end
          end
          resources :orders, path: "", only: [:index, :show], concerns: :ticketable do
            member do
              post :cancel
              get :seats
              post :create_billing
            end
            collection do
              get :search, path: "suche"
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
          post :add_coupon
          post :remove_coupon
        end
      end
    end

    scope controller: :orders, path: "tickets" do
      scope path: ":signed_info", constraints: { signed_info: /[\w_,~]+--\h+(--\d+)?/ }, as: :order_overview do
        get "/", action: :passbook_pass, constraints: { user_agent: /(Passbook|Wallet)/ }
        get "/", action: :show
        post "/", action: :check_email
        get "/wallet", action: :passbook_pass, as: :wallet
      end
    end

    namespace :members, path: "mitglieder" do
      resource :member, path: "mitgliedschaft", controller: :member, only: [:edit, :update] do
        member do
          get "aktivieren", action: :activate, as: :activate
          patch "finish_activation"
          get "passwort_vergessen", action: :forgot_password, as: :forgot_password
          post "reset_password"
        end
      end
      resources :dates, path: "termine", except: [:show]
      resources :files, path: "dateien", except: [:index, :show]

      get "login" => "sessions#new", as: :login
      post "login" => "sessions#create"
      get "logout" => "sessions#destroy", as: :logout

      root to: "main#index", as: :root
    end

  end

  scope path: :api, as: :api, constraints: { format: :json } do
    scope module: :api do
      resources :orders, only: [:create]
      scope controller: :seats, path: :seats, as: :seats do
        get "availability", action: :availability
        get "/", action: :index
      end
      # scope controller: :box_office, path: :box_office do
      #   get :search
      #   get :ticket_printable
      #   patch :pick_up_tickets
      #   post :place_order
      #   patch :cancel_order
      #   patch :cancel_tickets
      #   patch :enable_resale_for_tickets
      #   post :purchase
      #   post :unlock_seats
      #   get :event
      #   get :products
      #   get :report
      #   post :bill
      # end
      # scope controller: :check_in, path: :check_in do
      #   get "/", action: :index
      #   post "/", action: :create
      # end
      post "push_notifications" => "push_notifications#register"
    end

    passbook_routes

  end

end
