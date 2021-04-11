# frozen_string_literal: true

Rails.application.routes.draw do
  # dates
  scope controller: :dates, path: 'termine', as: :dates do
    root action: :teaser, as: ''
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
    get :freundeskreis
    get '/(:event_slug)', action: :index
  end
  get 'info', to: redirect('faq')

  # static pages
  scope controller: :static do
    get 'impressum'
    get 'satzung'
    get 'pressematerial', action: :press_material, as: :press_material

    # sometimes we might pause our contract with IT-Recht when we don't sell any
    # tickets for a longer period of time
    # in that case we're legally obligated to remove their content from our site
    if Settings.hide_it_recht_content
      privacy_redirect = redirect('datenschutz', status: 302)
      get 'agb', to: privacy_redirect
      get 'widerrufsbelehrung', as: :widerruf, to: privacy_redirect
      get 'datenschutz', action: :privacy_fallback, as: :privacy
    else
      get 'agb'
      get 'widerrufsbelehrung', action: :widerruf, as: :widerruf
      get 'datenschutz', action: :privacy, as: :privacy
    end

    root action: :index
  end

  scope controller: :sessions do
    get 'login', action: :new, as: :login
    post 'login', action: :create
    get 'logout', action: :destroy, as: :logout
  end

  direct(:eu_dispute_resolution) { 'https://ec.europa.eu/consumers/odr' }

  # resources
  scope path_names: { new: 'neu', edit: 'bearbeiten' } do
    resources :contact_messages, only: %i[index create], path: 'kontakt'

    # galleries
    resources :galleries, path: 'galerie' do
      resources :photos, path: 'fotos'
    end

    resource :newsletter_subscriber, path: :newsletter,
                                     only: %i[create edit update destroy] do
      get :confirm
    end

    namespace :admin, path: 'vorstand' do
      resources :documents, path: 'dokumente', except: :show
      resources :newsletters do
        post :finish, on: :member
        post :approve, on: :member
        resources :images, controller: :newsletter_images,
                           only: %i[create destroy]
      end
      resources :members_members, path: 'mitglieder', controller: :members do
        patch :reactivate, on: :member
        patch :resume_membership_fee_payments, on: :member
      end
      resources :members_membership_fee_payments,
                controller: :membership_fee_payments do
        patch :mark_as_failed, on: :member
      end
    end

    namespace :ticketing, path: '' do
      concern :ticketable do
        resource :tickets, only: [] do
          collection do
            patch :cancel, path: 'stornieren'
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
        scope path: 'bestellungen' do
          resource :order, path: '', only: [] do
            member do
              get 'neu/(:event_slug)', action: :new_privileged,
                                       as: :new_privileged
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
              post :resend_items
              get :seats
            end
            resources :billings, only: %i[create]
          end
        end
        scope controller: :payments, path: 'zahlungen', as: :payments do
          get '/', action: :index
          patch :mark_as_paid
          patch :approve
          post :submit
          get :submission_file, path: 'sepa-auftrag/:id'
        end
        resources :seatings, path: 'sitzpläne', only: %i[index show]
        resources :reservation_groups,
                  path: 'vorreservierungen',
                  only: %i[index show create update destroy]
        resources :coupons, path: 'gutscheine' do
          post :mail, on: :member
        end
      end

      resource :order, path: '', type: :web, only: [] do
        scope path: 'tickets' do
          get 'bestellen/(:event_slug)', action: :new, as: :new, on: :member
        end
        get 'geschenkgutscheine/bestellen', action: :new_coupons,
                                            as: :new_coupons, on: :member
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
        post :refund
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
      resources :dates, path: 'termine', except: %i[index show] do
        get :index, constraints: { format: :ics }, on: :collection
      end
      resources :documents, path: 'dokumente', except: %i[index show]

      scope controller: :dashboard do
        get '/', action: :index, as: :root
        get :videos
      end
    end
  end

  scope path: :api, as: :api, defaults: { format: :json } do
    scope module: :api do
      namespace :ticketing do
        resources :orders, only: [:create] do
          post :totals, on: :collection
        end

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

  scope controller: :shared_email_accounts, path: :shared_email_accounts do
    get :authorize, action: :token
    get 'credentials/:token', action: :credentials
  end

  resources :internet_access_sessions, path: :wlan, only: %i[new create],
                                       path_names: { new: '' }

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
