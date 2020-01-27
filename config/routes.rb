Rails.application.routes.draw do
  # dates
  scope controller: :dates, path: 'termine', as: :dates do
    root action: :index, as: ''
    get ':slug', action: :show_event, as: :event
  end

  # theater
  scope controller: :theater, path: 'theater', as: :theater do
    get '/', action: :index
    get ':slug', action: :show, as: :play
  end

  # info
  scope controller: :info, path: 'faq', as: :info do
    get 'map'
    get '/(:event_slug)', action: :index
  end
  get 'info', to: redirect('faq')

  # static pages
  scope controller: :static do
    get 'impressum'
    get 'satzung'
    get 'agb'
    get 'widerrufsbelehrung', action: :widerruf, as: :widerruf
    get 'datenschutz', action: :privacy, as: :privacy
    get 'pressematerial', action: :press_material, as: :press_material

    root action: :index
  end

  direct(:eu_dispute_resolution) { 'https://ec.europa.eu/consumers/odr' }

  # resources
  scope path_names: { new: 'neu', edit: 'bearbeiten' } do
    resources :contact_messages, only: %i[index create], path: 'kontakt'

    # galleries
    resources :galleries, path: 'galerie' do
      post 'sort', on: :collection

      resources :photos, path: 'fotos', except: :index do
        post 'sort', on: :collection
      end
    end

    resource :newsletter_subscriber, path: :newsletter,
                                     only: %i[create edit update destroy] do
      get :confirm
    end

    namespace :admin, path: 'vorstand' do
      resources :documents, path: 'dokumente', except: :show
      resources :newsletters do
        post :finish, on: :member
        resources :images, controller: :newsletter_images,
                           only: %i[create destroy]
      end
      resources :members_members, path: 'mitglieder', controller: :members do
        patch :reactivate, path: 'reaktivieren', on: :member
      end
    end

    namespace :ticketing, path: '' do
      concern :ticketable do
        resource :tickets, only: [] do
          collection do
            patch :cancel, path: 'stornieren'
            patch :enable_resale
            get :transfer, path: 'umbuchen'
            get :edit, path: 'bearbeiten'
            patch :update
            post :init_transfer
            patch :finish_transfer
            get :printable
          end
        end
      end

      scope path: 'vorverkauf' do
        scope controller: :statistics, path: 'statistik', as: :statistics do
          get '/', action: :index
          get 'seats/:date_id', action: :seats, as: :seats
          get 'chart_data', action: :chart_data, as: :chart_data
        end
        scope path: 'bestellungen', type: :admin do
          resource :order, path: '', only: [] do
            member do
              get 'neu/(:event_slug)', action: :new_admin, as: :new_admin
            end
            collection do
              post 'enable-reservation-groups',
                   action: :enable_reservation_groups,
                   as: :enable_reservation_groups
            end
          end
          resources :orders, path: '', only: %i[index show edit update],
                             concerns: :ticketable do
            member do
              post :send_pay_reminder
              post :resend_confirmation
              patch :mark_as_paid
              patch :approve
              post :resend_tickets
              get :seats
              post :create_billing
            end
          end
        end
        scope controller: :payments, path: 'zahlungen', as: :payments do
          get '/', action: :index
          patch :mark_as_paid
          patch :approve
          post :submit
          get :submission_file, path: 'sepa-auftrag/:id'
          get :credit_transfer_file, path: 'sepa-transfer'
        end
        resources :seatings, path: 'sitzpläne', only: %i[index show]
        resources :reservation_groups,
                  path: 'vorreservierungen',
                  only: %i[index show create update destroy]
        resources :coupons, path: 'gutscheine' do
          post :mail, on: :member
        end
      end

      scope as: :retail, path: 'vorverkaufsstelle', type: :retail do
        root to: redirect('/vorverkaufsstelle/bestellungen/neu'), type: ''
        get 'statistik' => 'statistics#index_retail', as: :statistics
        scope path: 'bestellungen' do
          resource :order, path: '', only: [] do
            get 'neu/(:event_slug)', action: :new_retail, as: :new, on: :member
          end
          resources :orders, path: '', only: %i[index show],
                             concerns: :ticketable do
            member do
              post :cancel
              get :seats
              post :create_billing
            end
          end
        end
        scope module: :retail do
          get 'login' => 'sessions#new', as: :login
          post 'login' => 'sessions#create'
          get 'logout' => 'sessions#destroy', as: :logout
        end
      end

      resource :order, path: 'tickets', type: :web, only: [] do
        get 'bestellen/(:event_slug)', action: :new, as: :new, on: :member
        collection do
          post :add_coupon
          post :remove_coupon
        end
      end
    end

    scope controller: :orders, path: 'tickets' do
      max_length = Ticketing::SigningKey.max_info_length
      info_regex = Regexp.new(/[A-Za-z0-9\-_]{1,#{max_length}}/)

      scope path: ':signed_info', constraints: { signed_info: info_regex },
            as: :order_overview do
        get '/', action: :passbook_pass,
                 constraints: { user_agent: /(Passbook|Wallet)/ }
        get '/', action: :show
        post '/', action: :check_email
        get '/wallet', action: :passbook_pass, as: :wallet
        get '/seats', action: :seats
      end
    end

    namespace :members, path: 'mitglieder' do
      resource :member, path: 'mitgliedschaft', controller: :member,
                        only: %i[edit update] do
        member do
          get 'aktivieren', action: :activate, as: :activate
          patch 'finish_activation'
          get 'passwort_vergessen', action: :forgot_password,
                                    as: :forgot_password
          post 'reset_password'
        end
      end
      resources :dates, path: 'termine', except: :show
      resources :documents, path: 'dokumente', except: %i[index show]

      get 'login' => 'sessions#new', as: :login
      post 'login' => 'sessions#create'
      get 'logout' => 'sessions#destroy', as: :logout

      root to: 'dashboard#index', as: :root
    end
  end

  scope path: :api, as: :api, defaults: { format: :json } do
    scope module: :api do
      namespace :ticketing do
        resources :orders, only: [:create]

        namespace :box_office do
          resources :events, only: :index
          resources :products, only: :index
          resources :orders, only: %i[index show create destroy]
          resources :tickets, only: [] do
            collection do
              get :show, constraints: { format: :pdf }
              patch :update
            end
          end
          resources :purchases, only: :create
          resource :seating, only: :show, defaults: { format: :html }
          resources :transactions, only: %i[index create]
        end

        resources :check_ins, only: %i[index create]

        namespace :node do
          resources :events, only: :index
        end
      end

      resources :members, only: %i[index show]
      post 'push_notifications' => 'push_notifications#register'

      scope path: :mobile_devices, controller: :mobile_devices do
        get :profile, as: :mobile_device_profile
        post :enroll, as: :enroll_mobile_device
      end
    end

    passbook_routes
  end

  scope path: :admin do
    require 'sidekiq/web'
    if Rails.env.production?
      Sidekiq::Web.use Rack::Auth::Basic do |username, password|
        credentials = Rails.application.credentials.sidekiq
        ActiveSupport::SecurityUtils.secure_compare(
          ::Digest::SHA256.hexdigest(username),
          ::Digest::SHA256.hexdigest(credentials.dig(:web, :username) ||
                                     SecureRandom.hex)
        ) &&
          ActiveSupport::SecurityUtils.secure_compare(
            ::Digest::SHA256.hexdigest(password),
            ::Digest::SHA256.hexdigest(credentials.dig(:web, :password) ||
                                       SecureRandom.hex)
          )
      end
    end
    mount Sidekiq::Web, at: 'sidekiq'
  end
end
